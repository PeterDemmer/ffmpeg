#!/bin/bash

umask 022

cd `dirname $0`
THIS=`basename $0 .sh`
LOG=log/$THIS.log
mkdir -p log    # crontab entry is using this before start of this script !
touch $LOG
echo "`date`   $0   begin" | tee -a $LOG
BEGINA=`date '+%s'`


YADIF="-vf yadif"
PRESET="-preset slower"
DILCRF="-crf 18"
STBCRF="-crf 18"
SBSCRF="-crf 21"
VIDSTBDT="-vf vidstabdetect=shakiness=10:accuracy=15:result="
VIDSTB="-c:v libx264  $PRESET  $STBCRF  -vf vidstabtransform=smoothing=12:zoom=0:input="
UNSHARP="unsharp=3:3:1.0:3:3:1.0"
VIDSBS="-filter_complex hstack,format=yuv420p  -c:v libx264  $SBSCRF"
NICE="nice -20"


#for VOB in ./VIDEO_TS/VTS_??_1.VOB 
for VOB in ./VIDEO_TS/VTS_07_1.VOB 
do
    BEGIN1=`date '+%s'`
    VTS=`echo $VOB  | sed 's/_1.VOB$//'`
    VTS1=${VTS}_1.VOB
    VTS2=${VTS}_2.VOB
    VTSQ=${VTS}_?.VOB
    VTSX=${VTS}.vob
    TRF=$VTS.trf
    MP4DIL=$VTS.dil.mp4
    MP4STB=$VTS.stb.mp4
    MP4SBS=$VTS.sbs.mp4
    #echo "$LINENO	VOB=$VOB	VTS1=$VTS1	VTS=$VTS	VTSX=$VTSX	VTSQ=$VTSQ	MP4=$MP4" | tee -a $LOG


    [ -f $VTS2 ] && {
        [ -f $VTSX ] && {
            echo "$LINENO	`basename $VTSX` already exists:" | tee -a $LOG
        } || {
            echo "$LINENO	cat $VTSQ > $VTSX" | tee -a $LOG
            $NICE cat $VTS1 $VTS2 > $VTSX
        }
    } || {
        VTSX=$VOB
    }
    echo "$LINENO	Source(s):	" | tee -a $LOG
    ls -l $VTSQ | sed 's/^/	/' | tee -a $LOG

    DURATIONR="`ffprobe $VTSX 2>&1 | grep Duration: | awk '{ printf $2 }'`"
    DURATION=`echo $DURATIONR | tr ':.' '  ' | awk '{ printf("%d s", $1 * 3600 + $2 * 60 + $3) }'`
    #echo "$LINENO	DURATIONR=$DURATIONR	DURATION=$DURATION"

    TIME=`date '+%s'`
    #echo $BEGIN1 $TIME $DURATION | awk '{ printf("Elapsed: %d:%02d\tslowdown: %.1f\n", ($2-$1)/60, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
    echo $BEGIN1 $TIME | awk '{ printf("Elapsed: %d:%02d\n", ($2-$1)/60, ($2-$1)%60) }' | tee -a $LOG
    echo "" | tee -a $LOG


    [ -f $MP4DIL ] && {
        echo -n "$LINENO	`basename $MP4DIL` already exists:	" | tee -a $LOG
        ls -l $MP4DIL | tee -a $LOG
        [ $VTSX -nt $MP4DIL ] && {
            echo "$LINENO	`basename $VTSX` is newer then `basename $MP4DIL`, please check:" | tee -a $LOG
            ls -l $VTSX | sed "s/^/$LINENO	" | tee -a $LOG
        }
    }   
    [ ! -f $MP4DIL ] && {
        echo "$LINENO	$NICE  ffmpeg  -i $VTSX  $YADIF  -c:v libx264  $PRESET  $DILCRF  -c:a copy  $MP4DIL" | tee -a $LOG
        $NICE  ffmpeg  -i $VTSX  $YADIF  -c:v libx264  $PRESET  $DILCRF  -c:a copy  $MP4DIL  2>$VTS.dil.err
        tail -5 $VTS.dil.err
    }
    ls -l ${VTS}* | egrep 'VOB$|.dil.mp4$' | sed "s/^/$LINENO	/" | tee -a $LOG
    TIME=`date '+%s'`
    #echo $BEGIN1 $TIME $DURATION | awk '{ printf("Elapsed: %d:%02d\tslowdown: %.1f\n", ($2-$1)/60, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
    echo $BEGIN1 $TIME | awk '{ printf("Elapsed: %d:%02d\n", ($2-$1)/60, ($2-$1)%60) }' | tee -a $LOG
    echo "" | tee -a $LOG


    [ -f $TRF ] && {
        echo -n "$LINENO	`basename $TRF` already exists:	" | tee -a $LOG
        ls -l $TRF  | tee -a $LOG
        [ $MP4DIL -nt $TRF ] && {
            echo -n "$LINENO	`basename $MP4DIL` is newer ! :	" | tee -a $LOG
            ls -l $MP4DIL | tee -a $LOG
        }
    }
    [ ! -f $TRF ] && {
        echo "$LINENO	$NICE  ffmpeg  -i $MP4DIL  $VIDSTBDT$TRF -f null -  2>$VTS.trerr" | tee -a $LOG
        $NICE  ffmpeg  -i $MP4DIL  $VIDSTBDT$TRF -f null -  2>$VTS.trerr
        ls -l $TRF $VTS.trerr | sed "s/^/$LINENO	/" | tee -a $LOG
    }
    TIME=`date '+%s'`
    #echo $BEGIN1 $TIME $DURATION | awk '{ printf("Elapsed: %d:%02d\tslowdown: %.1f\n", ($2-$1)/60, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
    echo $BEGIN1 $TIME | awk '{ printf("Elapsed: %d:%02d\n", ($2-$1)/60, ($2-$1)%60) }' | tee -a $LOG
    echo "" | tee -a $LOG


    [ -f $MP4STB ] && {
        echo -n "$LINENO	`basename $MP4STB` already exists:	" | tee -a $LOG
        ls -l $MP4STB  | tee -a $LOG
        [ $TRF -nt $MP4STB ] && {
            echo -n "$LINENO	* NOTE *	`basename $TRF` is newer:	" | tee -a $LOG
            ls -l $TRF | tee -a $LOG
        }
    }
    [ ! -f $MP4STB ] && {
        echo "$LINENO	$NICE  ffmpeg  -i $MP4DIL  $VIDSTB$TRF,$UNSHARP  -c:a copy  $MP4STB  2>$VTS.sterr" | tee -a $LOG
        $NICE  ffmpeg  -i $MP4DIL  $VIDSTB$TRF,$UNSHARP  -c:a copy   $MP4STB  2>$VTS.sterr
        ls -l $MP4STB $VTS.sterr | sed "s/^/$LINENO	/" | tee -a $LOG
    }
    TIME=`date '+%s'`
    #echo $BEGIN1 $TIME $DURATION | awk '{ printf("Elapsed: %d:%02d\tslowdown: %.1f\n", ($2-$1)/60, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
    echo $BEGIN1 $TIME | awk '{ printf("Elapsed: %d:%02d\n", ($2-$1)/60, ($2-$1)%60) }' | tee -a $LOG
    echo "" | tee -a $LOG


    [ -f $MP4SBS ] && {
        echo -n "$LINENO	`basename $MP4SBS` already exists:	" | tee -a $LOG
        ls -l $MP4SBS  | tee -a $LOG
        [ $MP4STB -nt $MP4SBS ] && {
            echo -n "$LINENO	*NOTE*	`basename $MP4STB` is newer:	" | tee -a $LOG
            ls -l $MP4STB | tee -a $LOG
        }
    }
    [ ! -f $MP4SBS ] && {
        echo "$LINENO	$NICE  ffmpeg  -i $MP4DIL  -i $MP4STB  $VIDSBS  $MP4SBS  2>$VTS.sberr" | tee -a $LOG
        $NICE  ffmpeg  -i $MP4DIL  -i $MP4STB  $VIDSBS  $MP4SBS  2>$VTS.sberr
        ls -l $MP4SBS $VTS.sberr | sed "s/^/$LINENO	/" | tee -a $LOG
    }


    EINDE=`date '+%s'`
    echo $BEGIN1 $EINDE $DURATION | awk '{ printf("Total: %d:%02d\tslowdown: %.1f\n", ($2-$1)/60, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
    echo "" | tee -a $LOG
    echo "" | tee -a $LOG

    [ -f $THIS.stop ] && {
        echo "$LINENO	$THIS.stop found, stopping." | tee -a $LOG
        echo "" | tee -a $LOG
        echo "" | tee -a $LOG
        echo "" | tee -a $LOG
        echo "" | tee -a $LOG
        exit 1
    }
done

EINDEA=`date '+%s'`
echo $BEGINA $EINDEA $DURATION | awk '{ printf("Total all: %dh%02dm%02d\tslowdown: %.1f\n", ($2-$1)/3600, (($2-$1)/60) % 3600, ($2-$1)%60, ($2-$1)/$3) }' | tee -a $LOG
echo "`date`   $0   finis" | tee -a $LOG
echo "" | tee -a $LOG
echo "" | tee -a $LOG

