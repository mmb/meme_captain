var MEMECAPTAIN = (function (window, $, fabric) {
    "use strict";

    var my = {},

        facebookAppId = '108445492580525',
        googleApiKey = 'ABQIAAAA-E0uJIHoMJX6M6atCgYANRS1DzXPXMqKnKNRJm2Z_PRWxvtqGBSOvBqyXOwxGZU5jLxExg_5ym69rw',
        genUrl = '/g',
        genDataType = genUrl === '/g' ? 'json' : 'jsonp',
        imageMaxSide = 800;

    function setSourceUrl(sourceUrl) {
        $('#u').val(sourceUrl).addClass('attn');
        $('#t1x,#t1y,#t1w,#t1h,#t2x,#t2y,#t2w,#t2h').val('');
        $('#positionTextCanvasDiv').empty();
        $('#positionTable').hide();
    }

    // scale width and height so that neither is larger than maxSide
    function resizeToFit(width, height, maxSide) {
        var result = {
                width : width,
                height : height
            };

        if (width > maxSide) {
            result.width = maxSide;
            result.height = Math.round(height * (maxSide / width));
        }

        if (result.height > maxSide) {
            result.width = Math.round(
                result.width * (maxSide / result.height)
            );
            result.height = maxSide;
        }

        return result;
    }

    // build an image search result thumbnail
    function searchThumbnail(thumbnailUrl, imgUrl, imgWidth, imgHeight) {
        var scaledDimensions = resizeToFit(imgWidth, imgHeight, imageMaxSide),
            title = scaledDimensions.width + ' x ' + scaledDimensions.height,
            thumbnailImage = $('<img />').attr({
                src : thumbnailUrl,
                title : title,
                width : scaledDimensions.width / 4.0,
                height : scaledDimensions.height / 4.0
            }).addClass('thumb');

        return thumbnailImage.click(function () { setSourceUrl(imgUrl); });
    }

    function showGoogleImages(resp) {
        var div = $('#imageSearchResults'),
            searchResults = resp.responseData.results;

        if (searchResults.length > 0) {
            $.each(searchResults, function (i, img) {
                div.append(searchThumbnail(img.tbUrl, img.unescapedUrl,
                    parseInt(img.width, 10), parseInt(img.height, 10)));
            });
        } else {
            div.append($('<p />').append('No Google results.'));
        }
    }

    function loadSourceImages() {
        $.get('source_images.json', function (data) {
            var pos = 0,
                div = $('#localSourceImages');

            $.each(data.images, function (i, img) {
                div.append($('<img />').attr('src',
                    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAAXNSR0IArs4c6QAAAAJiS0dEAACqjSMyAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3AIBAQMqmgCy0wAAAAtJREFUCNdjYGAAAAADAAEg1ZTHAAAAAElFTkSuQmCC'
                    ).addClass('thumb').css({
                    'background-image' : 'url(' + data.thumbSpritesUrl + ')',
                    'background-position' : pos + 'px 0px',
                    height : data.thumbHeight,
                    width : img.thumbWidth + 'px'
                }).click(function () { setSourceUrl(img.url); }));

                pos -= img.thumbWidth;
            });
        });
    }

    function imageSearch() {
        var imageSearchInput = $('#imageSearch'),
            imageSearchVal = imageSearchInput.val();

        if (imageSearchVal.match(/[^\s]/)) {
            imageSearchInput.val('');
            $('#imageSearchResults').empty();

            $.ajax({
                type : 'GET',
                url : 'http://ajax.googleapis.com/ajax/services/search/images',
                data : {
                    imgsz : 'large',
                    key : googleApiKey,
                    q : imageSearchVal,
                    rsz : '8',
                    v : '1.0'
                },
                dataType : 'jsonp',
                success : showGoogleImages
            });
        }
    }

    function positionText() {
        var imageUrl = $('#u').val(),
            canvas;

        if (imageUrl.length > 0) {
            $('#positionTable').show();
            $('#positionTextCanvasDiv').empty().append($('<canvas />').attr({
                id : 'positionTextCanvas'
            }));

            canvas = new fabric.Canvas('positionTextCanvas');

            canvas.setBackgroundImage(imageUrl, function () {
                var canvasSize = resizeToFit(canvas.backgroundImage.width,
                    canvas.backgroundImage.height, imageMaxSide),
                    textWidth,
                    textHeight,
                    rect1,
                    rect2;

                canvas.setWidth(canvasSize.width);
                canvas.setHeight(canvasSize.height);

                canvas.renderAll.bind(canvas);

                textWidth = 0.9 * canvas.getWidth();
                textHeight = 0.25 * canvas.getHeight();

                rect1 = new fabric.Rect({
                    top  : textHeight / 2.0,
                    left : canvas.getWidth() / 2.0,
                    width : textWidth,
                    height : textHeight,
                    fill : 'red',
                    cornersize : 20
                });

                rect1.name = '1';
                rect1.set('lockRotation', true);

                canvas.add(rect1);

                rect2 = new fabric.Rect({
                    top : canvas.getHeight() - (textHeight / 2.0),
                    left : canvas.getWidth() / 2.0,
                    width : textWidth,
                    height : textHeight,
                    fill : 'red',
                    cornersize : 20
                });

                rect2.name = '2';
                rect2.set('lockRotation', true);

                canvas.add(rect2);

                canvas.observe('object:moving', function (o) {
                    var target = o.target,

                        halfWidth = target.getWidth() / 2,
                        leftSide = Math.round(target.getLeft() - halfWidth),
                        rightSide = Math.round(target.getLeft() + halfWidth),

                        halfHeight = target.getHeight() / 2,
                        topSide = Math.round(target.getTop() - halfHeight),
                        bottomSide = Math.round(target.getTop() + halfHeight);

                    if (leftSide < 0) {
                        target.setLeft(halfWidth);
                    }
                    if (rightSide > canvas.getWidth()) {
                        target.setLeft(canvas.getWidth() - halfWidth);
                    }
                    if (topSide < 0) {
                        target.setTop(halfHeight);
                    }
                    if (bottomSide > canvas.getHeight()) {
                        target.setTop(canvas.getHeight() - halfHeight);
                    }
                });

                canvas.observe('object:modified', function (o) {
                    var target = o.target;

                    $('#t' + target.name + 'x').val(
                        Math.round(target.getLeft() - (target.getWidth() / 2))
                    );
                    $('#t' + target.name + 'y').val(
                        Math.round(target.getTop() - (target.getHeight() / 2))
                    );
                    $('#t' + target.name + 'w').val(Math.round(target.getWidth()));
                    $('#t' + target.name + 'h').val(Math.round(target.getHeight()));
                });

                canvas.observe('object:scaling', function (o) {
                    var target = o.target,
                        maxScaleX = canvas.width / target.width,
                        maxScaleY = canvas.height / target.height;

                    if (target.scaleX > maxScaleX) {
                        target.scaleX = maxScaleX;
                    }

                    if (target.scaleY > maxScaleY) {
                        target.scaleY = maxScaleY;
                    }

                    canvas.fire('object:moving', { target : target });
                });

                canvas.fire('object:modified', { target : rect1 });
                canvas.fire('object:modified', { target : rect2 });
            });
        }
    }

    function imgurLink(url) {
        return $('<a />').attr('href',
            'http://api.imgur.com/2/upload?url=' +
            encodeURIComponent(url)).append('imgur');
    }

    function redditLink(url) {
        return $('<a />').attr('href',
            'http://www.reddit.com/submit?url=' +
            encodeURIComponent(url)).append('reddit');
    }

    // build a Twitter tweet link for a url
    function tweetLink(url) {
        return $('<a />').attr({
            href : 'http://twitter.com/share',
            'class' : 'twitter-share-button',
            'data-count' : 'none',
            'data-text' : ' ',
            'data-url' : url
        }).append('Tweet');
    }

    // build Twitter tweet script tag
    function tweetScript() {
        return $('<script />').attr(
            'src',
            'http://platform.twitter.com/widgets.js'
        );
    }

    // build Facebook Like div for a url
    function facebookLikeDiv(url) {
        return $('<div />').attr('id', 'fb-root').addClass('share').append(
            $('<fb:like />').attr({
                href : url,
                send : 'true',
                width : '450',
                show_faces : 'true',
                font : ''
            })
        );
    }

    // Facebook asynchronous init
    function fbAsyncInit() {
        FB.init({
            appId : facebookAppId,
            status : true,
            cookie : true,
            xfbml : true
        });
    }

    function facebookScript() {
        return $('<script />').attr({
            src : 'http://connect.facebook.net/en_US/all.js'
        });
    }

    function createImage() {
        var createdImageDiv,
            uVal = $('#u').val();

        if (uVal !== '') {
            createdImageDiv = $('#createdImage');

            $('#positionTextCanvasDiv').empty();

            createdImageDiv.prepend($('<p />').append('Creating image ...'));

            $.get(genUrl, {
                u  : uVal,
                t1 : $('#t1').val(),
                t2 : $('#t2').val(),

                t1x : $('#t1x').val(),
                t1y : $('#t1y').val(),
                t1w : $('#t1w').val(),
                t1h : $('#t1h').val(),

                t2x : $('#t2x').val(),
                t2y : $('#t2y').val(),
                t2w : $('#t2w').val(),
                t2h : $('#t2h').val()
            }, function (data) {
                var img = $('<img />').attr('src', data.imageUrl),
                    imgLink = $('<a />').attr('href', data.imageUrl).append(
                        data.imageUrl
                    ),
                    templateLink = $('<a />').attr(
                        'href',
                        data.templateUrl
                    ).append(data.templateUrl);

                createdImageDiv.empty().append(img).append(
                    $('<p />').append('Image: ').append(imgLink)
                );

                // template link
                createdImageDiv.append(
                    $('<p />').append('To make more with this source image: ').
                        append(templateLink)
                );

                // imgur link
                createdImageDiv.append($('<div />').addClass(
                    'share'
                ).append(imgurLink(data.imageUrl)));

                // reddit link
                createdImageDiv.append($('<div />').addClass(
                    'share'
                ).append(redditLink(data.imageUrl)));

                // tweet link
                createdImageDiv.append($('<div />').addClass('share').append(
                    tweetLink(data.imageUrl)
                ).append(tweetScript()));

                // Facebook like
                createdImageDiv.append(facebookLikeDiv(data.imageUrl));
                window.fbAsyncInit = fbAsyncInit;
                createdImageDiv.append(facebookScript());
            }, genDataType).error(function (j) {
                createdImageDiv.empty().append($('<p />').text(j.responseText));
            });
        }
    }

    my.init = function () {
        loadSourceImages();

        $('#imageSearch').keypress(function (event) {
            if (event.which === 13) {
                event.preventDefault();
                imageSearch();
            }
        });

        $('#imageSearchButton').click(imageSearch);

        $('#positionTextButton').click(positionText);

        $('#createImageButton').click(createImage);

        $('#upload').change(function () {
            $('#uploadSubmit').removeAttr('disabled');
        });

        // highlight input fields that have been preloaded from the query string
        $(":text[value!='']").addClass('attn');

        if (!window.CanvasRenderingContext2D) {
            $('.hasCanvas').hide();
            $('.noCanvas').show();
        }
    };

    return my;
}(window, $, fabric));

$(MEMECAPTAIN.init);
