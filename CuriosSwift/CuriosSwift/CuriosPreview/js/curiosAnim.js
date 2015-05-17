/**
* Created by Allen on 2015/4/29.
*/
window.requestAnimFrame = (function() {
    return  window.requestAnimationFrame        ||
        window.webkitRequestAnimationFrame          ||
        window.mozRequestAnimationFrame             ||
        window.oRequestAnimationFrame               ||
        window.msRequestAnimationFrame              ||
        function(callback) {
            window.setTimeout(callback, 1000 / 60);
        };
})();

var Engine = {

    FRAME_RATE: 60,

    createNew:function(a){

        var engine = {};
        var obj       = a.obj;
        var delay     = a.delay;
        var duration  = a.duration;
        var repeat    = a.repeat;
        var isReverse = a.isReverse;
        var isKeep    = a.isKeep;
        var easeType  = a.easeType;
        var keyFrames    = a.keyFrames;
        var reverseFrames;

        var isPlaying   = false;
        var isPaused    = false;
        var isReversPlaying = false;
        var frames     = 0;
        var progress   = 0;
        var delayFrames = 0;
        var holdFrame;
        var playTimes;

        var isPlayFrame = false;
        var isLoadFrame = false;

        engine.play = function(){
            if(!isPaused) {
                if(!isPlaying){
                    frames      = 0;
                    progress    = 0;
                    delayFrames = delay/1000 * Engine.FRAME_RATE;
                    holdFrame = keyFrames[0];
                    playTimes = repeat;
                    isPlaying = true;
                    isPaused   = false;
                    isReversPlaying = false;
                    a.frameStart();
                    setReverseKeyFrames();
                    onFrame();
                    loadFrame();
                }
            }else{
                isPaused    = false;
                isPlaying   = true;
                onFrame();
            }
        };

        engine.pause = function(){
            isPaused  = true;
            isPlaying = false;
            isPlayFrame = false;
        };

        engine.stop = function(){
            isPaused  = false;
            isPlaying = false;
            isPlayFrame = false;
            setObjFrame(holdFrame);
        };

        var loadFrame = function () {
            if(!isLoadFrame){
                animFrame();
            }
            isLoadFrame = true;
        };

        var animFrame = function(){
            requestAnimFrame(animFrame);
            if(isPlayFrame){
                onFrame();
            }
        };

        var setReverseKeyFrames = function(){
            reverseFrames = new Array();
            for(var i = keyFrames.length; i >0; i--) {
                reverseFrames.push(keyFrames[i-1]);
            }
        };

        var onFrame = function(){
            isPlayFrame = false;
            progress    = (frames - delayFrames - 1) / (duration / 1000*Engine.FRAME_RATE);
            if(progress < 0) {
                frames ++;
                a.frameProgress(0);
                isPlayFrame = true;
                return
            }
            var kfs;
            if(isReversPlaying) {
                kfs  = reverseFrames;
            }else {
                kfs  = keyFrames;
            }
            var keyFrameIndex    = parseInt(kfs.length * progress);
            var km;
            if(easeType != 'empty') {

            }else{
                if(keyFrameIndex >= kfs.length) {
                    keyFrameIndex = kfs.length - 1;
                }
                km = kfs[keyFrameIndex];
                setObjFrame(km);

                frames++;
                if(progress >= 1) {
                    if((isReverse ) && (!isReversPlaying)) {
                        isPlaying = true;
                        isReversPlaying  = true;
                        frames = 0;
                    } else {
                        if(this._isReversPlaying) {
                            setObjFrame(holdFrame);
                            frames = 0;
                            isPlaying       = false;
                            isReversPlaying = false;
                            a.frameEnd();
                            return;
                        }else {
                            if(repeat != 0){
                                if(!isKeep){
                                    setObjFrame(holdFrame);
                                }
                                playTimes --;
                                if(playTimes == 0) {
                                    frames = 0;
                                    isPlaying       = false;
                                    isReversPlaying = false;
                                    a.frameEnd();
                                    return
                                }else{
                                    frames = 0;
                                    isReversPlaying = false;
                                }
                            }else{
                                frames = 0;
                                isReversPlaying = false;
                            }
                        }
                    }
                } else {
                    if(!isReverse) {
                        a.frameProgress(progress);
                    }else{
                        if(!isReversPlaying){
                            a.frameProgress(progress/2);
                        }else{
                            a.frameProgress(0.5+progress/2);
                        }
                    }
                }
                if(isPlaying){
                    isPlayFrame = true;
                }
            }
        };

        var setObjFrame = function(frame){
            var es = obj.style;
            es.left = frame.frameX + 'px';
            es.top  = frame.frameY + 'px';
            if(frame.frameWidth >= 0){
                es.width = frame.frameWidth + 'px';
            } else {
                es.width = '1px';
            }
            if(frame.frameHeight >= 0){
                es.height = frame.frameHeight + 'px';
            } else {
                es.height = '1px';
            }
            es.opacity  = frame.frameAlpha;

            es.webkitPerspective = es.msPerspective = es.mozPerspective = es.perspective = frame.framePerspective;
            var rotationStr = 'rotate('+frame.frameRotation+'deg) ';
            var rotationXStr    = 'rotateX('+frame.frameRotationX+'deg) ';
            var rotationYStr    = 'rotateY('+frame.frameRotationY+'deg) ';
            var scaleStr        = 'scale3d('+frame.frameScaleX+', '+frame.frameScaleY+', '+frame.frameScaleZ+ ') ';
            var translateStr = 'translate3d('+frame.frameTranslateX+'px, '+frame.frameTranslateY+'px, '+ frame.frameTranslateZ+'px) ';
            var transformStr = translateStr + rotationStr + rotationXStr + rotationYStr  + scaleStr;
            es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = transformStr;

            //console.log("x = "+frame.frameX+"y = "+frame.frameY+"w = "+frame.frameWidth+"h = "+frame.frameHeight+"a = "+frame.frameAlpha+"transform = "+transformStr)
        };
        return engine;
    }
};

var CuriosAnim = {
    createNew : function(a){
        var animation = {};

        var engineFrame = Object.create(EngineFrame);
        engineFrame.obj      = a.obj;
        engineFrame.delay     = a.delay===undefined?0:a.delay;
        engineFrame.duration  = a.duration===undefined?5000:a.duration;
        engineFrame.repeat    = a.repeat===undefined?1:a.repeat;
        engineFrame.isReverse = a.isReverse===undefined?false:a.isReverse;
        engineFrame.isKeep    = a.isKeep===undefined?true:a.isKeep;
        engineFrame.easeType  = a.easeType===undefined?'empty':a.easeType;
        engineFrame.frameStart    = a.frameStart===undefined?function(){}:a.frameStart;
        engineFrame.frameProgress = a.frameProgress===undefined?function(progress){}:a.frameProgress;
        engineFrame.frameEnd   = a.frameEnd===undefined?function(){}:a.frameEnd;

        var leftFrom = GetCurrentStyle(a.obj, "left")==='auto'?0:parseFloat(GetCurrentStyle(a.obj, "left"));
        var topFrom  = GetCurrentStyle(a.obj, "top")==='auto'?0:parseFloat(GetCurrentStyle(a.obj, "top"));
        var widthFrom = parseFloat(GetCurrentStyle(a.obj, "width"));
        var heightFrom = parseFloat(GetCurrentStyle(a.obj, "height"));
        var alphaFrom = parseFloat(GetCurrentStyle(a.obj, "opacity"));
        var perspectiveFrom = GetCurrentStyle(a.obj, "-webkit-perspective")==='none'?0:parseFloat(GetCurrentStyle(a.obj, "-webkit-perspective"));
        var transformStr    = GetCurrentStyle(a.obj,"-webkit-transform");
        var rotationFrom;
        var rotationXFrom;
        var rotationYFrom;
        var scaleXFrom;
        var scaleYFrom;
        var scaleZFrom;
        var translateXFrom;
        var translateYFrom;
        var translateZFrom;
        if(transformStr == "none") {
            rotationFrom = 0;
            rotationXFrom = 0;
            rotationYFrom = 0;
            scaleXFrom = 1;
            scaleYFrom = 1;
            scaleZFrom = 1;
            translateXFrom = 0;
            translateYFrom = 0;
            translateZFrom = 0;
        } else {
            var transReg = /(matrix\()/i;
            if(transformStr.match(transReg) != null) {
                rotationFrom = 0;
                rotationXFrom = 0;
                rotationYFrom = 0;
                scaleXFrom = 1;
                scaleYFrom = 1;
                scaleZFrom = 1;
                translateXFrom = 0;
                translateYFrom = 0;
                translateZFrom = 0;
            }else{
                var rotationReg = /(rotate\([\-\+]?((\d{0,}\.{0,1}\d{0,})(deg))\))/i;
                var rotationArray = transformStr.match(rotationReg);
                var rotationStr = '';
                if(rotationArray != null){
                    rotationStr =rotationArray[0];
                    rotationStr=rotationStr.substring(rotationStr.indexOf('(')+1,rotationStr.length-4);
                    rotationFrom = parseFloat(rotationStr);
                }else{
                    rotationReg = /(rotateZ\([\-\+]?((\d{0,}\.{0,1}\d{0,})(deg))\))/i;
                    rotationArray = transformStr.match(rotationReg);
                    if(rotationArray != null){
                        rotationStr =rotationArray[0];
                        rotationStr=rotationStr.substring(rotationStr.indexOf('(')+1,rotationStr.length-4);
                        rotationFrom = parseFloat(rotationStr);
                    }else{
                        rotationFrom = 0;
                    }
                }

                var rotationXReg = /(rotateX\([\-\+]?((\d{0,}\.{0,1}\d{0,})(deg))\))/i;
                var rotationXArray = transformStr.match(rotationXReg);
                if(rotationXArray != null){
                    var rotationXStr =rotationXArray[0];
                    rotationXStr=rotationXStr.substring(rotationXStr.indexOf('(')+1,rotationXStr.length-4);
                    rotationXFrom = parseFloat(rotationXStr);
                }else{
                    rotationXFrom = 0;
                }

                var rotationYReg = /(rotateY\([\-\+]?((\d{0,}\.{0,1}\d{0,})(deg))\))/i;
                var rotationYArray = transformStr.match(rotationYReg);
                if(rotationYArray != null){
                    var rotationYStr =rotationYArray[0];
                    rotationYStr=rotationYStr.substring(rotationYStr.indexOf('(')+1,rotationYStr.length-4);
                    rotationYFrom = parseFloat(rotationYStr);
                }else{
                    rotationYFrom = 0;
                }

                var scaleReg = /(scale3d\([\-\+]?(\d{0,}\.{0,1}\d{0,}), [\-\+]?(\d{0,}\.{0,1}\d{0,}), [\-\+]?(\d{0,}\.{0,1}\d{0,})\))/i;
                var scaleArray = transformStr.match(scaleReg);
                var scaleStr = '';
                if(scaleArray != null){
                    scaleStr = scaleArray[0];
                    scaleStr = scaleStr.substring(scaleStr.indexOf('(')+1,scaleStr.length-1);
                    scaleArray = scaleStr.split(", ");
                    scaleXFrom = parseFloat(scaleArray[0]);
                    scaleYFrom = parseFloat(scaleArray[1]);
                    scaleZFrom = parseFloat(scaleArray[2]);
                }else{
                    scaleReg = /(scale\([\-\+]?(\d{0,}\.{0,1}\d{0,}), [\-\+]?(\d{0,}\.{0,1}\d{0,})\))/i;
                    scaleArray = transformStr.match(scaleReg);
                    if(scaleArray != null){
                        scaleStr = scaleArray[0];
                        scaleStr = scaleStr.substring(scaleStr.indexOf('(')+1,scaleStr.length-1);
                        scaleArray = scaleStr.split(", ");
                        scaleXFrom = parseFloat(scaleArray[0]);
                        scaleYFrom = parseFloat(scaleArray[1]);
                        scaleZFrom = 1;
                    }else{
                        scaleReg = /(scale\([\-\+]?(\d{0,}\.{0,1}\d{0,})\))/i;
                        scaleArray = transformStr.match(scaleReg);
                        if(scaleArray != null){
                            scaleStr = scaleArray[0];
                            scaleStr = scaleStr.substring(scaleStr.indexOf('(')+1,scaleStr.length-1);
                            scaleXFrom = parseFloat(scaleStr);
                            scaleYFrom = parseFloat(scaleStr);
                            scaleZFrom = 1;
                        }else{
                            scaleXFrom = 1;
                            scaleYFrom = 1;
                            scaleZFrom = 1;
                        }
                    }
                }

                var translateReg = /(translate3d\([\-\+]?((\d{0,}\.{0,1}\d{0,})(px)), [\-\+]?((\d{0,}\.{0,1}\d{0,})(px)), [\-\+]?((\d{0,}\.{0,1}\d{0,})(px))\))/i;
                var translateArray = transformStr.match(translateReg);
                var translateStr = '';
                if(translateArray != null){
                    translateStr = translateArray[0];
                    translateStr = translateStr.substring(translateStr.indexOf('(')+1,translateStr.length-1);
                    translateArray = translateStr.split(", ");
                    translateXFrom = parseFloat(translateArray[0]);
                    translateYFrom = parseFloat(translateArray[1]);
                    translateZFrom = parseFloat(translateArray[2]);
                }else{
                    translateReg = /(translate\([\-\+]?((\d{0,}\.{0,1}\d{0,})(px)), [\-\+]?((\d{0,}\.{0,1}\d{0,})(px))\))/i;
                    translateArray = transformStr.match(translateReg);
                    if(translateArray != null){
                        translateStr = translateArray[0];
                        translateStr = translateStr.substring(translateStr.indexOf('(')+1,translateStr.length-1);
                        translateArray = translateStr.split(", ");
                        translateXFrom = parseFloat(translateArray[0]);
                        translateYFrom = parseFloat(translateArray[1]);
                        translateZFrom = 0;
                    }else{
                        translateXFrom = 0;
                        translateYFrom = 0;
                        translateZFrom = 0;
                    }
                }
            }

        }
        var keyFrames = new Array();
        keyFrames.push({
            frameX:leftFrom,
            frameY:topFrom,
            frameWidth:widthFrom,
            frameHeight:heightFrom,
            frameAlpha:alphaFrom,
            framePerspective:perspectiveFrom,
            frameRotation:rotationFrom,
            frameRotationX:rotationXFrom,
            frameRotationY:rotationYFrom,
            frameScaleX:scaleXFrom,
            frameScaleY:scaleYFrom,
            frameScaleZ:scaleZFrom,
            frameTranslateX:translateXFrom,
            frameTranslateY:translateYFrom,
            frameTranslateZ:translateZFrom
        });
        var endFrames  = a.endFrames;
        var framesDuration = a.duration;
        var leavePercentage = 1;
        for(var i = 0; i < endFrames.length ; i ++)
        {
            var endFrame = endFrames[i];
            var frameDurationProgress = endFrame.framePercentage===undefined?leavePercentage:endFrame.framePercentage;
            if(i == endFrames.length - 1) {
                frameDurationProgress = leavePercentage;
                leavePercentage = 0;
            }else{
                leavePercentage = leavePercentage - frameDurationProgress;
            }

            var frameDuration = framesDuration * frameDurationProgress;
            var leftTo    = endFrame.frameX===undefined?leftFrom:endFrame.frameX;
            var topTo     = endFrame.frameY===undefined?topFrom:endFrame.frameY;
            var widthTo    = endFrame.frameWidth===undefined?widthFrom:endFrame.frameWidth;
            var heightTo   = endFrame.frameHeight===undefined?heightFrom:endFrame.frameHeight;
            var alphaTo    = endFrame.frameAlpha===undefined?alphaFrom:endFrame.frameAlpha;
            var perspectiveTo = endFrame.framePerspective===undefined?perspectiveFrom:endFrame.framePerspective;
            var rotationTo    = endFrame.frameRotation===undefined?rotationFrom:endFrame.frameRotation;
            var rotationXTo   = endFrame.frameRotationX===undefined?rotationXFrom:endFrame.frameRotationX;
            var rotationYTo   = endFrame.frameRotationY===undefined?rotationYFrom:endFrame.frameRotationY;
            var scaleXTo   = endFrame.frameScaleX===undefined?scaleXFrom:endFrame.frameScaleX;
            var scaleYTo   = endFrame.frameScaleY===undefined?scaleYFrom:endFrame.frameScaleY;
            var scaleZTo   = endFrame.frameScaleZ===undefined?scaleZFrom:endFrame.frameScaleZ;
            var translateXTo   = endFrame.frameTranslateX===undefined?translateXFrom:endFrame.frameTranslateX;
            var translateYTo   = endFrame.frameTranslateY===undefined?translateYFrom:endFrame.frameTranslateY;
            var translateZTo   = endFrame.frameTranslateZ===undefined?translateZFrom:endFrame.frameTranslateZ;

            var frames = frameDuration / 1000*Engine.FRAME_RATE;
            var leftRate    = ( leftTo - leftFrom ) / frames;
            var topRate    = ( topTo - topFrom ) / frames;
            var widthRate    = ( widthTo - widthFrom ) / frames;
            var heightRate    = ( heightTo - heightFrom ) / frames;
            var alphaRate    = ( alphaTo - alphaFrom ) / frames;
            var perspectiveRate    = (perspectiveTo - perspectiveFrom) / frames;
            var rotationRate    = ( rotationTo - rotationFrom ) / frames;
            var rotationXRate    = ( rotationXTo - rotationXFrom ) / frames;
            var rotationYRate    = ( rotationYTo - rotationYFrom ) / frames;
            var scaleXRate    = ( scaleXTo - scaleXFrom ) / frames;
            var scaleYRate    = ( scaleYTo - scaleYFrom ) / frames;
            var scaleZRate    = ( scaleZTo - scaleZFrom ) / frames;
            var translateXRate    = ( translateXTo - translateXFrom ) / frames;
            var translateYRate    = ( translateYTo - translateYFrom ) / frames;
            var translateZRate    = ( translateZTo - translateZFrom ) / frames;
            var keyFrame = 0;
            while(keyFrame < frames) {
                if(keyFrame < frames - 1){
                    keyFrames.push({
                        frameX:leftFrom+=leftRate,
                        frameY:topFrom+=topRate,
                        frameWidth:widthFrom+=widthRate,
                        frameHeight:heightFrom+=heightRate,
                        frameAlpha:alphaFrom+=alphaRate,
                        framePerspective:perspectiveFrom+=perspectiveRate,
                        frameRotation:rotationFrom+=rotationRate,
                        frameRotationX:rotationXFrom+=rotationXRate,
                        frameRotationY:rotationYFrom+=rotationYRate,
                        frameScaleX:scaleXFrom+=scaleXRate,
                        frameScaleY:scaleYFrom+=scaleYRate,
                        frameScaleZ:scaleZFrom+=scaleZRate,
                        frameTranslateX:translateXFrom+=translateXRate,
                        frameTranslateY:translateYFrom+=translateYRate,
                        frameTranslateZ:translateZFrom+=translateZRate
                    });
                }else{
                    keyFrames.push({
                        frameX:leftTo,
                        frameY:topTo,
                        frameWidth:widthTo,
                        frameHeight:heightTo,
                        frameAlpha:alphaTo,
                        framePerspective:perspectiveTo,
                        frameRotation:rotationTo,
                        frameRotationX:rotationXTo,
                        frameRotationY:rotationYTo,
                        frameScaleX:scaleXTo,
                        frameScaleY:scaleYTo,
                        frameScaleZ:scaleZTo,
                        frameTranslateX:translateXTo,
                        frameTranslateY:translateYTo,
                        frameTranslateZ:translateZTo
                    });
                }
                keyFrame++;
            }
        }
        engineFrame.keyFrames = keyFrames;

        var engine = Engine.createNew(engineFrame);

        animation.play = function(){
            engine.play();
        };

        animation.pause = function(){
            engine.pause();
        };

        animation.stop = function(){
            engine.stop();
        };

        return animation;
    }
};

var EngineFrame = {
    obj:'',
    delay:0,
    duration:1000,
    repeat:1,
    isReverse:false,
    isKeep:false,
    easeType:'empty',
    keyFrames: [{
        frameX:1,
        frameY:1,
        frameWidth:200,
        frameHeight:200,
        frameAlpha:0.2,
        framePerspective:0,
        frameRotation:30,
        frameRotationX:0,
        frameRotationY:0,
        frameScaleX:1,
        frameScaleY:1,
        frameScaleZ:1,
        frameTranslateX:0,
        frameTranslateY:0,
        frameTranslateZ:1
    }],
    frameStart: function(){
    },
    frameProgress: function (progress) {
    },
    frameEnd:function() {
    }
};

var animationFrame = {
    obj:'',
    delay:0,
    duration:1000,
    repeat:1,
    isReverse:false,
    isKeep:false,
    easeType:'empty',
    endFrames: [{
        framePercentage:1,
        frameX:1,
        frameY:1,
        frameWidth:200,
        frameHeight:200,
        frameAlpha:0.2,
        framePerspective:0,
        frameRotation:400,
        frameRotationX:0,
        frameRotationY:0,
        frameScaleX:1,
        frameScaleY:1,
        frameScaleZ:1,
        frameTranslateX:0,
        frameTranslateY:0,
        frameTranslateZ:1
    }],
    frameStart: function(){
    },
    frameProgress: function (progress) {
    },
    frameEnd:function(){
    }
};

function GetCurrentStyle (obj, prop) {
    if(obj.style[prop] != "") {
        return obj.style[prop];
    } else if (obj.currentStyle) {
        return obj.currentStyle[prop];
    } else if (window.getComputedStyle) {
        propprop = prop.replace (/([A-Z])/g, "-$1");
        propprop = prop.toLowerCase ();
        return document.defaultView.getComputedStyle (obj,null)[prop];
    }
    return null;
}
