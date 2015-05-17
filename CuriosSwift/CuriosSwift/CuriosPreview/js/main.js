/**
 * Created by Allen on 2015/5/7.
 */
(function(){
    var resPath = './res',
        mainJsonPath = "/main.json",
        fileID,
        fileAuthorID,
        mainHeight,
        mainWidth,
        mainTile,
        mainDesc,
        flipType,
        flipDirection,
        flipLoop,
        mainBackground,
        mainMusic,
        pagesPath,
        pages,
        publishDate;
    var fileScale,
        fileHeight,
        fileWidth;

    var currentSlideID,
        currentSlidePage,
        nextSlideID,
        nextSlidePage,
        preSlideID,
        preSlidePage,
        currentIndex;

    var deviceWidth,
        deviceHeight;
    var pageLoadIndex;
    var MainFile = {
        init:function(mainJson){
            fileID         = mainJson.ID;
            fileAuthorID   = mainJson.AuthorID;
            mainWidth      = mainJson.MainWidth;
            mainHeight     = mainJson.MainHeight;
            mainTile       = mainJson.MainTitle;
            mainDesc       = mainJson.MainDesc;
            flipDirection  = mainJson.FlipDirection;
            flipType       = mainJson.FlipType;
            flipLoop       = mainJson.FlipLoop == 'true'?true:false;
            mainBackground = mainJson.MainBackground;
            mainMusic      = mainJson.MainMusic;
            pagesPath      = mainJson.PagesPath;
            pages          = mainJson.Pages;
            publishDate    = mainJson.PublishDate;

            this.setScreenSize();
            this.changeViewsport();
            this.setMainDiv();
            this.loadPageJson();

            $(window).on('resize', function() {
                MainFile.setScreenSize();
                MainFile.setMainDivCss();
                setCurrentPage();
                resetSlidePostition();
            });
        },

        setScreenSize:function(){
            deviceWidth = $(window).width();
            deviceHeight = $(window).height();

            var c1 = mainWidth / mainHeight;
            var c2 = deviceWidth / deviceHeight;
            if (c1 > c2) {
                fileScale = deviceWidth / mainWidth;
            }else {
                fileScale = deviceHeight / mainHeight;
            }
            fileWidth = fileScale * mainWidth;
            fileHeight = fileScale * mainHeight;
        },

        changeViewsport:function(){
            var ua = navigator.userAgent;
            if (/Android (\d+\.\d+)/.test(ua)) {
                var version = parseFloat(RegExp.$1);
                // andriod 2.3
                if (version > 2.3) {
                    document.write('<meta name="viewport" content="width=' + mainWidth + ', minimum-scale=' + fileScale + ', maximum-scale=' + fileScale + ', target-densitydpi=device-dpi"/>');
                    // andriod 2.3����
                } else {
                    document.write('<meta name="viewport" content="width=' + mainWidth + ', target-densitydpi=device-dpi"/>');
                }
                // ios
            } else if (/iPhone (\d+\.\d+)/.test(ua) || /iPad (\d+\.\d+)/.test(ua)) {
                document.write('<meta name="viewport" content="width=' + mainWidth + ', user-scalable=no, target-densitydpi=device-dpi"/>');
            }else {
                //document.write('<meta name="viewport" content="width='+fileWidth+', user-scalable=yes">')
            }
        },

        setMainDiv:function(){
            var mainDevClass   = '<div id="'+"mainDiv"+'"/>';
            $("body").append(mainDevClass);
            var slideContaierDivClass = '<div class="'+"slideContainer"+'"/>';
            $("#mainDiv").append(slideContaierDivClass);
            this.setMainDivCss();
        },

        setMainDivCss:function(){
            $("#mainDiv").css({
                "position":"absolute",
                "left": "0px",
                "top": "0px",
                "width": deviceWidth,
                "height": deviceHeight,
                "background-color": "black"
            });
            $(".slideContainer").css({
                "position":"relative",
                "width": fileWidth + "px",
                "height": fileHeight + "px",
                "margin": "0 auto",
                "-webkit-perspective":"1200px",
                "-moz-perspective":"1200px",
                "-ms-perspective":"1200px",
                "perspective":"1200px"
            });
            if (mainBackground != "" && mainBackground != null) {
                $(".slideContainer").css({
                    "background": "url(" + resPath + mainBackground + ")",
                    "-moz-background-size": "100% 100%",
                    "background-size": "100% 100%",
                    "background-repeat": "no-repeat"
                });
            }
        },

        loadPageJson:function(){
            pageLoadIndex = 0;
            this.loadSignPageJson();
        },

        loadSignPageJson:function(){
            if(pageLoadIndex < pages.length){
                var pageObject = pages[pageLoadIndex];
                var signPath = pageObject.Path;
                var pageIndex = pageObject.Index;
                var pageID    = pageObject.PageID;
                var pagePath = resPath + pagesPath+signPath;
                var pageJson;
                for(var i=0; i < curiosPagesJson.length; i++){
                    var signJson = curiosPagesJson[i];
                    if(signJson.ID == pageID){
                        pageJson = signJson;
                        break;
                    }
                }
                if(pageJson != null){
                    var pageClass =  PageClass.createNew(pageJson, pagePath);
                    pages.splice(pageLoadIndex,1,pageClass);
                }else{
                    pages.splice(pageLoadIndex,1);
                }
                pageLoadIndex++;
                MainFile.loadSignPageJson();
            }else{
                initSlidePage();
            }
        }
    };

    var initSlidePage = function(){
        switch (flipType){
            case "translate3d":
                var translateClass = TranslateSlideClass.createNew();
                translateClass.init();
                break;
            default :
                break;
        }
    };

    var resetSlidePostition = function(){
        switch (flipType){
            case "translate3d":
                var translateClass = TranslateSlideClass.createNew();
                translateClass.resetPosition();
                break;
            default :
                break;
        }
    };

    var getPageClassByID = function(pageID){
        for(var i=0 ; i < pages.length; i ++){
            var pageClass = pages[i];
            if(pageClass.pageID == pageID){
                return pageClass;
            }
        }
        return null;
    };

    var setCurrentPage = function(){
        var currentPageClass = pages[currentIndex];
        currentSlideID = currentPageClass.pageID;
        var currentPageJquery  =  $("#"+currentSlideID);
        if(currentPageJquery.length == 0){
            currentPageClass.initView();
        }else{
            currentPageClass.resetSize();
        }
        currentSlidePage   = $("#"+currentSlideID)[0];

        var nextIndex = -1;
        if(currentIndex == pages.length -1){
            if(flipLoop){
                nextIndex = 0;
            }
        }else{
            nextIndex = currentIndex + 1;
        }

        var preIndex = -1;
        if(currentIndex == 0) {
            if(flipLoop){
                preIndex = pages.length - 1;
            }
        }else{
            preIndex = currentIndex - 1;
        }

        if(nextIndex == -1|| (preIndex == nextIndex && currentIndex == pages.length -1)){
            nextSlideID   = null;
            nextSlidePage = null;
        }else{
            var nextPageClass = pages[nextIndex];
            nextSlideID = nextPageClass.pageID;
            var nextPageJquery  =  $("#"+nextSlideID);
            if(nextPageJquery.length == 0){
                nextPageClass.initView();
            }else{
                nextPageClass.resetSize();
            }
            nextSlidePage  =  $("#"+nextSlideID)[0];
        }

        if(preIndex == -1 || (preIndex == nextIndex && currentIndex == 0)){
            preSlideID   = null;
            preSlidePage = null;
        }else{
            var prePageClass = pages[preIndex];
            preSlideID = prePageClass.pageID;
            var prePageJquery  =  $("#"+preSlideID);
            if(prePageJquery.length == 0){
                prePageClass.initView();
            }else{
                prePageClass.resetSize();
            }
            preSlidePage  =  $("#"+preSlideID)[0];
        }
    };

    var TranslateSlideClass = {
        createNew:function(){
            var translateSlideClass = {};

            var beginSlideTime;
            var isBeginSlide;
            var slideBeginX;
            var slideBeginY;
            var startX;
            var startY;
            var isPlayAnimation = false;
            var isLoadComplete  = false;
            var slideDir        = '';

            translateSlideClass.init = function(){
                currentIndex = 0;
                setCurrentPage();
                document.getElementById(currentSlideID).addEventListener('pageLoaded', function(){
                    isLoadComplete = true;
                    var currentPageClass = pages[currentIndex];
                    currentPageClass.beginView();
                });
                setPagePosition();
                addCurrentPageEvent();
            };

            translateSlideClass.resetPosition = function(){
                setPagePosition();
            };

            var setPagePosition = function(){
                var currentSlidePageWidth  = parseFloat(GetCurrentStyle(currentSlidePage,"width"));
                var currentSlidePageHeight = parseFloat(GetCurrentStyle(currentSlidePage, "height"));
                var es = currentSlidePage.style;
                es.left = (fileWidth-currentSlidePageWidth)/2+"px";
                es.top  = (fileHeight-currentSlidePageHeight)/2+"px";
                es.zIndex = 0;
                es.webkitTransformStyle = es.MsTransformStyle = es.msTransformStyle = es.MozTransformStyle = es.OTransformStyle = es.transformStyle = "preserve-3d";
                if(nextSlideID != null && nextSlidePage != null){
                    var nextSlidePageWidth  = parseFloat(GetCurrentStyle(nextSlidePage,"width"));
                    var nextSlidePageHeight = parseFloat(GetCurrentStyle(nextSlidePage,"height"));
                    if(flipDirection == 'ver'){
                        nextSlidePage.style.left = (fileWidth-nextSlidePageWidth)/2+"px";
                        nextSlidePage.style.top  = fileHeight+"px";
                    }else if(flipDirection == 'hor'){
                        nextSlidePage.style.left = fileWidth+"px";
                        nextSlidePage.style.top  = (fileHeight-nextSlidePageHeight)/2+"px";
                    }
                    nextSlidePage.style.zIndex = 1;
                    $("#"+nextSlideID).hide();
                }
                if(preSlideID != null && preSlidePage != null){
                    var preSlidePageWidth  = parseFloat(GetCurrentStyle(preSlidePage,"width"));
                    var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                    if(flipDirection == 'ver'){
                        preSlidePage.style.left = (fileWidth-preSlidePageWidth)/2+"px";
                        preSlidePage.style.top  = 0-preSlidePageHeight+"px";
                    }else if(flipDirection == 'hor'){
                        preSlidePage.style.left = 0-preSlidePageWidth+"px";
                        preSlidePage.style.top  = (fileHeight-preSlidePageHeight)/2+"px";
                    }
                    preSlidePage.style.zIndex = 1;
                    $("#"+preSlideID).hide();
                }
            };

            var addCurrentPageEvent = function(){
                currentSlidePage.addEventListener('mousedown', mouseDown, true);
                // Events exclusive to touch devices
                currentSlidePage.addEventListener('touchstart', touchStart, false);
            };

            var removeCurrentPageEvent = function(){
                currentSlidePage.removeEventListener('mousedown', mouseDown, true);
                // Events exclusive to touch devices
                currentSlidePage.removeEventListener('touchstart', touchStart, false);
            };

            var mouseDown = function(event){
                if(isLoadComplete){
                    currentSlidePage.addEventListener('mousemove', mouseMove, true);
                    currentSlidePage.addEventListener('mouseup', mouseUp, true);
                    var x = event.pageX,
                        y = event.pageY;
                    beginSlide(x,y);
                }
            };

            var mouseMove = function(event){
                var x = event.pageX,
                    y = event.pageY;
                divSlide(x,y);
            };

            var mouseUp = function(event){
                currentSlidePage.removeEventListener('mousemove', mouseMove, true);
                currentSlidePage.removeEventListener('mouseup', mouseUp, true);
                var x = event.pageX,
                    y = event.pageY;
                slideEnd(x,y);
            };

            var touchStart = function(event){
                event.preventDefault();
                if(isLoadComplete){
                    if(event.touches.length == 1)
                    {
                        currentSlidePage.addEventListener('touchmove', touchMove, false);
                        currentSlidePage.addEventListener('touchend', touchEnd, false);
                        var touch = event.touches[0],
                            x = touch.pageX,
                            y = touch.pageY;
                        beginSlide(x,y);
                    }
                }
            };

            var touchMove = function(event){
                event.preventDefault();
                if(event.touches.length == 1)
                {
                    var touch = event.touches[0],
                        x = touch.pageX,
                        y = touch.pageY;
                    divSlide(x,y);
                }
            };

            var touchEnd = function(event){
                event.preventDefault();
                currentSlidePage.removeEventListener('touchmove', touchMove, false);
                currentSlidePage.removeEventListener('touchend', touchEnd, false);
                slideEnd();
            };

            var beginSlide = function(x, y){
                if(isPlayAnimation){
                    return;
                }
                var d = new Date();
                beginSlideTime = d.getTime();
                isBeginSlide = true;
                startX = x;
                startY = y;
                slideBeginX = x;
                slideBeginY = y;
                if(nextSlideID != null){
                    $("#"+nextSlideID).show();
                }
                if(preSlideID != null){
                    $("#"+preSlideID).show();
                }
            };

            var divSlide = function(x,y){
                if(isPlayAnimation){
                    return;
                }
                if(isBeginSlide) {
                    switch (flipDirection) {
                        case 'ver':
                            verSlide(y);
                            break;
                        case 'hor':
                            horSlide(x);
                            break;
                        default :
                            break;
                    }
                    slideBeginX = x;
                    slideBeginY = y;
                }
            };

            var slideEnd = function(x, y){
                if(isPlayAnimation){
                    return;
                }
                var endX = x===undefined?slideBeginX:x;
                var endY = y===undefined?slideBeginY:y;
                isBeginSlide = false;
                var d = new Date();
                var endSlideTime = d.getTime();
                if((endSlideTime - beginSlideTime) > 10){
                    switch (flipDirection) {
                        case 'ver':
                            verSlideAnimation(endY);
                            break;
                        case 'hor':
                            horSlideAnimation(endX);
                            break;
                        default :
                            break;
                    }
                }else{
                    if(nextSlideID != null){
                        $("#"+nextSlideID).hide();
                    }
                    if(preSlideID != null){
                        $("#"+preSlideID).hide();
                    }
                }
            };

            var verSlide = function(y){
                var changeY = y - slideBeginY;
                var beginChangeY = y - startY;
                var translate, scale;
                var progress;
                var preTop;
                var nextTop;
                if(preSlideID != null && preSlidePage != null){
                    preTop = parseFloat(GetCurrentStyle(preSlidePage, "top"))+changeY;
                    preSlidePage.style.top = preTop +'px';
                }
                if(nextSlideID != null && nextSlidePage != null){
                    nextTop = parseFloat(GetCurrentStyle(nextSlidePage, "top"))+changeY;
                    nextSlidePage.style.top = nextTop +'px';
                }
                if(changeY > 0){
                    slideDir = 'pre';
                }else if(changeY < 0){
                    slideDir = 'next';
                }else{
                    slideDir = '';
                }
                if(beginChangeY > 0){
                    if(preSlideID != null && preSlidePage != null){
                        var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                        progress = (preTop + preSlidePageHeight) / fileHeight;
                    } else{
                        progress = beginChangeY/fileHeight*0.2;
                    }
                }else if(beginChangeY < 0){
                    if(nextSlideID != null && nextSlidePage != null){
                        progress = (nextTop - fileHeight) / fileHeight;
                    } else{
                        progress = beginChangeY/fileHeight*0.2;
                    }
                }else {
                    progress = 0;
                }
                var es = currentSlidePage.style;
                var currentSlidePageHeight =parseFloat(GetCurrentStyle(currentSlidePage, "height"));
                scale = 1 - Math.min(Math.abs(progress * 0.2), 1);
                if(beginChangeY < 0){
                    translate = (scale - 1) * currentSlidePageHeight/2;
                }else if(beginChangeY > 0){
                    translate  = (1 - scale) * currentSlidePageHeight/2;
                }
                var scaleStr        = 'scale(' + scale + ')';
                var translateStr    = 'translate3d(0,' + (translate) + 'px,0) ';
                es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = translateStr +  scaleStr ;
            };

            var horSlide = function(x){
                var changeX = x - slideBeginX;
                var beginChangeX = x - startX;
                var translate, scale;
                var progress;
                var preLeft;
                var nextLeft;
                if(preSlideID != null && preSlidePage != null){
                    preLeft = parseFloat(GetCurrentStyle(preSlidePage, "left"))+changeX;
                    preSlidePage.style.left = preLeft +'px';
                }
                if(nextSlideID != null && nextSlidePage != null){
                    nextLeft = parseFloat(GetCurrentStyle(nextSlidePage, "left"))+changeX;
                    nextSlidePage.style.left = nextLeft +'px';
                }
                if(changeX > 0){
                    slideDir = 'pre';
                }else if(changeX < 0){
                    slideDir = 'next';
                }else{
                    slideDir = '';
                }
                if(beginChangeX > 0){
                    if(preSlideID != null && preSlidePage != null){
                        var preSlidePageWidth = parseFloat(GetCurrentStyle(preSlidePage, "width"));
                        progress = (preLeft + preSlidePageWidth) / fileWidth;
                    } else{
                        progress = beginChangeX/fileWidth*0.2;
                    }
                }else if(beginChangeX < 0){
                    if(nextSlideID != null && nextSlidePage != null){
                        progress = (nextLeft - fileWidth) / fileWidth;
                    } else{
                        progress = beginChangeX/fileWidth*0.2;
                    }
                }else {
                    progress = 0;
                }
                var es = currentSlidePage.style;
                var currentSlidePageWidth =parseFloat(GetCurrentStyle(currentSlidePage, "width"));
                scale = 1 - Math.min(Math.abs(progress * 0.2), 1);
                if(beginChangeX < 0){
                    translate = (scale - 1) * currentSlidePageWidth/2;
                }else if(beginChangeX > 0){
                    translate  = (1 - scale) * currentSlidePageWidth/2;
                }
                var scaleStr        = 'scale(' + scale + ')';
                var translateStr    = 'translate3d(' + (translate) + 'px,0,0) ';
                es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = translateStr +  scaleStr ;
            };

            var verSlideAnimation = function(y){
                var beginChangeY = y - startY;
                var finallyScale = 0.8;
                var currentSlidePageHeight = parseFloat(GetCurrentStyle(currentSlidePage, "height"));
                if(beginChangeY > 5){
                    if(preSlideID != null && preSlidePage != null){
                        if(slideDir != 'pre'){
                            resetCurrentPage();
                        }else{
                            var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                            var preTop             = parseFloat(GetCurrentStyle(preSlidePage, "top"));
                            var progress           = (0 - preTop)/preSlidePageHeight;
                            var time               = progress * 500 < 100 ? 100 : progress * 500;
                            var preSlideAnimation = CuriosAnim.createNew( {
                                obj: preSlidePage,
                                delay: 0,
                                duration: time,
                                endFrames: [{
                                    frameY:(fileHeight - preSlidePageHeight)/2
                                }]
                            });
                            preSlideAnimation.play();
                            var finallyTranslateY = (1-finallyScale) * currentSlidePageHeight/2;
                            var currentSlideAnimation = CuriosAnim.createNew( {
                                obj: currentSlidePage,
                                delay: 0,
                                duration: time,
                                endFrames: [{
                                    frameScaleX:finallyScale,
                                    frameScaleY:finallyScale,
                                    frameTranslateY:finallyTranslateY
                                }],
                                frameEnd: function () {
                                    preAnimationEnd();
                                }
                            });
                            isPlayAnimation = true;
                            currentSlideAnimation.play();
                        }
                    }else{
                        resetCurrentPage();
                    }
                    if(nextSlideID != null && nextSlidePage != null){
                        var nextSlidePageWidth  = parseFloat(GetCurrentStyle(nextSlidePage,"width"));
                        nextSlidePage.style.left = (fileWidth-nextSlidePageWidth)/2+"px";
                        nextSlidePage.style.top  = fileHeight+"px";
                    }
                }else if(beginChangeY < -5){
                    if(nextSlideID != null && nextSlidePage != null){
                        if(slideDir != 'next'){
                            resetCurrentPage();
                        }else{
                            var nextSlidePageHeight = parseFloat(GetCurrentStyle(nextSlidePage, "height"));
                            var nextTop            = parseFloat(GetCurrentStyle(nextSlidePage, "top"));
                            var progress           = nextTop/nextSlidePageHeight;
                            var time               = progress * 500 < 100 ? 100 : progress * 500;
                            var nextSlideAnimation = CuriosAnim.createNew( {
                                obj: nextSlidePage,
                                delay: 0,
                                duration: time,
                                endFrames: [{
                                    frameY:(fileHeight - nextSlidePageHeight)/2
                                }]
                            });
                            nextSlideAnimation.play();
                            var finallyTranslateY = (finallyScale - 1) * currentSlidePageHeight/2;
                            var currentSlideAnimation = CuriosAnim.createNew( {
                                obj: currentSlidePage,
                                delay: 0,
                                duration: time,
                                endFrames: [{
                                    frameScaleX:finallyScale,
                                    frameScaleY:finallyScale,
                                    frameTranslateY:finallyTranslateY
                                }],
                                frameEnd: function () {
                                    nextAnimationEnd();
                                }
                            });
                            isPlayAnimation = true;
                            currentSlideAnimation.play();
                        }
                    }else{
                        resetCurrentPage();
                    }
                    if(preSlideID != null && preSlidePage != null){
                        var preSlidePageWidth  = parseFloat(GetCurrentStyle(preSlidePage,"width"));
                        var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                        preSlidePage.style.left = (fileWidth-preSlidePageWidth)/2+"px";
                        preSlidePage.style.top  = 0-preSlidePageHeight+"px";
                    }
                }else{
                    if(nextSlideID != null){
                        $("#"+nextSlideID).hide();
                    }
                    if(preSlideID != null){
                        $("#"+preSlideID).hide();
                    }
                    resetCurrentPage();
                }
            };

            var horSlideAnimation = function(x){
                var beginChangeX = x - startX;
                var finallyScale = 0.8;
                var currentSlidePageWidth = parseFloat(GetCurrentStyle(currentSlidePage, "width"));
                if(beginChangeX > 5){
                    if(preSlideID != null && preSlidePage != null){
                        var preSlidePageWidth = parseFloat(GetCurrentStyle(preSlidePage, "width"));
                        var preLeft           = parseFloat(GetCurrentStyle(preSlidePage, "left"));
                        var progress          = (0 - preLeft)/preSlidePageWidth;
                        var time              = progress * 500 < 100 ? 100 : progress * 500;
                        var preSlideAnimation = CuriosAnim.createNew( {
                            obj: preSlidePage,
                            delay: 0,
                            duration: time,
                            endFrames: [{
                                frameX:(fileWidth - preSlidePageWidth)/2
                            }]
                        });
                        preSlideAnimation.play();
                        var finallyTranslateX = (1-finallyScale) * currentSlidePageWidth/2;
                        var currentSlideAnimation = CuriosAnim.createNew( {
                            obj: currentSlidePage,
                            delay: 0,
                            duration: time,
                            endFrames: [{
                                frameScaleX:finallyScale,
                                frameScaleY:finallyScale,
                                frameTranslateX:finallyTranslateX
                            }],
                            frameEnd: function () {
                                preAnimationEnd();
                            }
                        });
                        isPlayAnimation = true;
                        currentSlideAnimation.play();
                    }else{
                        resetCurrentPage();
                    }
                    if(nextSlideID != null && nextSlidePage != null){
                        var nextSlidePageWidth  = parseFloat(GetCurrentStyle(nextSlidePage,"width"));
                        var nextSlidePageHeight = parseFloat(GetCurrentStyle(nextSlidePage,"height"));
                        preSlidePage.style.left = fileWidth+"px";
                        preSlidePage.style.top  = (fileHeight-nextSlidePageWidth)/2+"px";
                    }
                }else if(beginChangeX < -5){
                    if(nextSlideID != null && nextSlidePage != null){
                        var nextSlidePageWidth = parseFloat(GetCurrentStyle(nextSlidePage, "width"));
                        var nextLeft           = parseFloat(GetCurrentStyle(nextSlidePage, "left"));
                        var progress           = nextLeft/nextSlidePageWidth;
                        var time               = progress * 500 < 100 ? 100 : progress * 500;
                        var nextSlideAnimation = CuriosAnim.createNew( {
                            obj: nextSlidePage,
                            delay: 0,
                            duration: time,
                            endFrames: [{
                                frameX:(fileWidth - nextSlidePageWidth)/2
                            }]
                        });
                        nextSlideAnimation.play();
                        var finallyTranslateX = (finallyScale - 1) * currentSlidePageWidth/2;
                        var currentSlideAnimation = CuriosAnim.createNew( {
                            obj: currentSlidePage,
                            delay: 0,
                            duration: time,
                            endFrames: [{
                                frameScaleX:finallyScale,
                                frameScaleY:finallyScale,
                                frameTranslateX:finallyTranslateX
                            }],
                            frameEnd: function () {
                                nextAnimationEnd();
                            }
                        });
                        isPlayAnimation = true;
                        currentSlideAnimation.play();
                    }else{
                        resetCurrentPage();
                    }
                    if(preSlideID != null && preSlidePage != null){
                        var preSlidePageWidth  = parseFloat(GetCurrentStyle(preSlidePage,"width"));
                        var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                        preSlidePage.style.left = 0-preSlidePageWidth+"px";
                        preSlidePage.style.top  = (fileHeight-preSlidePageHeight)/2+"px";
                    }
                }else{
                    if(nextSlideID != null){
                        $("#"+nextSlideID).hide();
                    }
                    if(preSlideID != null){
                        $("#"+preSlideID).hide();
                    }
                    resetCurrentPage();
                }
            };

            var resetCurrentPage = function(){

                if(preSlideID != null && preSlidePage != null){
                    switch (flipDirection) {
                        case 'ver':
                            resetVerPrePage();
                            break;
                        case 'hor':
                            resetHorPrePage();
                            break;
                        default :
                            break;
                    }
                }

                if(nextSlideID != null && nextSlidePage != null){
                    switch (flipDirection){
                        case 'ver':
                            resetVerNextPage();
                            break;
                        case 'hor':
                            resetHorNextPage();
                            break;
                        default :
                            break;
                    }

                }

                var currentSlideAnimation = CuriosAnim.createNew( {
                    obj: currentSlidePage,
                    delay: 0,
                    duration: 100,
                    endFrames: [{
                        frameScaleX:1,
                        frameScaleY:1,
                        frameTranslateY:0,
                        frameTranslatex:0
                    }],
                    frameEnd: function () {
                        isPlayAnimation = false;
                    }
                });
                isPlayAnimation = true;
                currentSlideAnimation.play();
            };

            var resetVerPrePage = function(){
                var preSlidePageHeight = parseFloat(GetCurrentStyle(preSlidePage, "height"));
                var preSlideAnimation = CuriosAnim.createNew({
                    obj: preSlidePage,
                    delay: 0,
                    duration: 100,
                    endFrames: [{
                        frameY:0-preSlidePageHeight
                    }]
                });
                preSlideAnimation.play();
            };

            var resetVerNextPage = function(){
                var nextSlideAnimation = CuriosAnim.createNew({
                    obj: nextSlidePage,
                    delay: 0,
                    duration: 100,
                    endFrames: [{
                        frameY:fileHeight
                    }]
                });
                nextSlideAnimation.play();
            };

            var resetHorPrePage = function(){
                var preSlidePageWidth  = parseFloat(GetCurrentStyle(preSlidePage,"width"));
                var preSlideAnimation = CuriosAnim.createNew({
                    obj: preSlidePage,
                    delay: 0,
                    duration: 100,
                    endFrames: [{
                        frameX:0-preSlidePageWidth
                    }]
                });
                preSlideAnimation.play();
            };

            var resetHorNextPage = function(){
                var nextSlideAnimation = CuriosAnim.createNew({
                    obj: nextSlidePage,
                    delay: 0,
                    duration: 100,
                    endFrames: [{
                        frameY:fileWidth
                    }]
                });
                nextSlideAnimation.play();
            };

            var nextAnimationEnd = function(){
                resetCurrentSlide();
                if(currentIndex == pages.length-1){
                    if(flipLoop){
                        currentIndex = 0;
                    }
                }else{
                    currentIndex ++ ;
                }
                if(preSlideID != null && preSlidePage != null){
                    var preClass = getPageClassByID(preSlideID);
                    preClass.removeView();
                }
                setCurrentPage();
                if(nextSlideID != null){
                    document.getElementById(nextSlideID).addEventListener('pageLoaded',function(){
                        isLoadComplete = true;
                    });
                }else{
                    isLoadComplete = true;
                }
                var currentPageClass = pages[currentIndex];
                currentPageClass.beginView();
                addCurrentPageEvent();
                setPagePosition();
                isPlayAnimation = false;
            };

            var preAnimationEnd = function(){
                resetCurrentSlide();
                if(currentIndex == 0 ){
                    if(flipLoop){
                        currentIndex = pages.length - 1
                    }
                }else{
                    currentIndex -- ;
                }
                if(nextSlideID != null && nextSlidePage != null){
                    var nextClass = getPageClassByID(nextSlideID);
                    nextClass.removeView();
                }
                setCurrentPage();
                if(preSlideID != null){
                    document.getElementById(preSlideID).addEventListener('pageLoaded',function(){
                        isLoadComplete = true;
                    });
                }else{
                    isLoadComplete = true;
                }
                var currentPageClass = pages[currentIndex];
                currentPageClass.beginView();
                addCurrentPageEvent();
                setPagePosition();
                isPlayAnimation = false;
            };

            var resetCurrentSlide = function(){
                var es = currentSlidePage.style;
                var scaleStr        = 'scale(' + 1 + ')';
                var translateStr    = 'translate3d(0,' + 0 + 'px,0) ';
                es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = translateStr +  scaleStr ;
                $("#"+currentSlideID).hide();
                removeCurrentPageEvent();
                isLoadComplete = false;
            };
            return translateSlideClass;
        }
    };


    var PageClass = {
        createNew:function(pageJson, pagePath){
            var pageClass = {};
            var pageID   = pageClass.pageID  = pageJson.ID;
            var pageWidth  = pageJson.PageWidth;
            var pageHeight = pageJson.PageHeight;
            var jsonContainers = pageJson.Containers;
            var containers = new Array();

            var loadIndex  = 0;
            for(var i = 0 ; i < jsonContainers.length ; i ++){
                var containerJson = jsonContainers[i];
                var containerClass = ContainerClass.createNew(containerJson, pagePath);
                containers.push(containerClass);
            }

            pageClass.initView = function(){
                var pageDiv = '<div id="'+pageID+'"/>';
                $(".slideContainer").append(pageDiv);
                setPageSize();
                loadIndex = 0;
                for(var i=0; i < containers.length; i++){
                    var containerClass = containers[i];
                    var containerID = containerClass.containerID;
                    if(containerClass.initView(pageID)){
                        var page = document.getElementById(pageID);
                        if(page != null){
                            page.addEventListener('containerLoaded', containerLoaded);
                        }
                    }else{
                        containers.splice(i,1);
                        i --;
                    }
                }
                if(containers.length == 0){
                    setTimeout(function(){
                        var event = new Event('pageLoaded');
                        document.getElementById(pageID).dispatchEvent(event);
                    }, 20);
                }
            };

            pageClass.resetSize = function(){
                setPageSize();
                for(var i=0; i < containers.length; i++){
                    var containerClass = containers[i];
                    containerClass.resetPosition();
                }
            };

            var setPageSize = function(){
                $("#"+pageID).css({
                    "position":"absolute",
                    "width": pageWidth*fileScale + "px",
                    "height": pageHeight*fileScale + "px",
                    "background-color":"rgba(255,255,255,1)"

                });
            };

            var containerLoaded = function(){
                loadIndex ++ ;
                if(loadIndex == containers.length){
                    setTimeout(function(){
                        var event = new Event('pageLoaded');
                        document.getElementById(pageID).dispatchEvent(event);
                    }, 20);
                }
            };

            pageClass.removeView = function(){
                $("#"+pageID).remove();
            };

            pageClass.beginView = function(){

            };

            return pageClass;
        }
    };

    var ContainerClass = {
        createNew:function(containerJson, pagePath){
            var containerClass = {};
            var containerID  = containerClass.containerID = containerJson.ID;
            var containerX           = containerJson.ContainerX;
            var containerY           = containerJson.ContainerY;
            var containerWidth       = containerJson.ContaienrWidth;
            var containerHeight      = containerJson.ContainerHeight;
            var containerRotation    = containerJson.ContainerRotation;
            var containerAlpha       = containerJson.ContainerAplha;
            var containerComponent   = containerJson.Component;
            var containerAnimations  = containerJson.Animations;
            var containerBehaviors   = containerJson.Behaviors;
            var containerEffects     = containerJson.Effects;

            containerClass.initView = function(pageID){
                var component = getComponent(containerComponent);
                var result = false;
                if(component != null){
                    component.initView(pageID,componentLoaded,componentLoadError);
                    setPosition();
                    result = true;
                }else{
                    result = false;
                }
                return result;
            };

            var componentLoaded = function(pageID){
                setPosition();
                if(pageID != null){
                    setTimeout(function(){
                        var event = new Event('containerLoaded');
                        var page  = document.getElementById(pageID);
                        if(page != null){
                            page.dispatchEvent(event);
                        }
                    }, 20);
                }
            };

            var componentLoadError = function(pageID){
                setPosition();
                if(pageID != null){
                    setTimeout(function(){
                        var event = new Event('containerLoaded');
                        document.getElementById(pageID).dispatchEvent(event);
                    }, 20);
                }
            };

            containerClass.resetPosition = function(){
                setPosition();
            };

            var setPosition = function(){
                var componentView = $("#"+containerID);
                if(componentView.length > 0){
                    componentView.css({
                        "position":"absolute"
                    });
                    var es = componentView[0].style;
                    es.left = containerX*fileScale + 'px';
                    es.top  = containerY*fileScale + 'px';
                    if(containerWidth >= 0){
                        es.width = containerWidth*fileScale + 'px';
                    } else {
                        es.width = '1px';
                    }
                    if(containerHeight >= 0){
                        es.height = containerHeight*fileScale + 'px';
                    } else {
                        es.height = '1px';
                    }
                    es.opacity  = containerAlpha;
                    var rotationStr = 'rotate('+containerRotation+'deg) ';
                    es.webkitTransform = es.MsTransform = es.msTransform = es.MozTransform = es.OTransform = es.transform = rotationStr;
                }
            };

            var getComponent = function(componentJson){
                var componentType = componentJson.ComponentType;
                var componentData = componentJson.ComponentData;
                switch(componentType){
                    case 'Image':
                        return ImageComponentClass.createNew(componentData, containerID, pagePath);
                        break;
                    default :
                        break;
                }
                return null;
            };
            return containerClass;
        }
    };

    var ImageComponentClass = {
        createNew:function(imageJson, containerID, pagePath){
            var imageClass = {};
            var imageID   = containerID;
            var imagePath = pagePath + imageJson.ImagePath;

            imageClass.initView = function(pageID, loaded, loadError){
                var o= new Image();
                o.src = imagePath;
                if(o.complete){
                    showImage(pageID, imagePath);
                    loaded(pageID);
                }else{
                    o.onload = function(){
                        showImage(pageID, imagePath);
                        loaded(pageID);
                    };
                    o.onerror = function(){
                        showImage(pageID, 'images/error.jpeg');
                        loadError(pageID);
                    };
                }
            };

            var showImage = function(pageID, path){
                var imageDiv = '<img id="'+imageID+'" src="'+path+'"/>';
                $("#"+pageID).append(imageDiv);
            };
            return imageClass;
        }
    };

    window.onload = function(){
        MainFile.init(curiosMainJson);
    };
}());