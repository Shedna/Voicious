###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Camera extends Module
    constructor : (emitter) ->
        super emitter
        do @appendHTML
        @jqMainCams       = ($ '#mainCam')
        @jqVideoContainer = ($ 'ul#videos')
        @zoomCams         = { }
        @streams          = [ ]
        @mosaicNb         = 1
        @diaporama        = off
        @diapoIndex       = 0
        @emitter.on 'stream.create', @newStream
        @emitter.on 'stream.state', @changeStreamState
        @emitter.on 'stream.remove', (event, user) =>
            for key, value of @zoomCams
                if key is user.id
                    @zoom user.id, undefined
                    return
        @emitter.on 'peer.remove', @delStream
        @emitter.on 'camera.localstream', (event, video) =>
            video.muted = yes
            @newStream event, { video : video , uid : window.Voicious.currentUser._id , local : yes }
        do @diaporamaMode
        ($ window).on 'resize', () =>
            videos = ($ 'video')
            for video in videos
                @centerVideoTag ($ video)
            do @resizeZoomCams
        ($ document).on 'DOMNodeInserted', 'video', (event) =>
            @centerVideoTag ($ event.currentTarget)
        ($ '#feeds').delegate '.zoomBtn', 'click', (event) =>
            clickButton = ($ event.target)
            mainLi = clickButton.parents 'li.thumbnail-wrapper'
            video = (mainLi.find 'video')
            if video?
                @zoom (video.attr 'rel'), video

    delStream   : (event, user) =>
        if (@streams.indexOf user.id) >= 0
            do ($ "li#video_#{user.id}").remove
            @streams.splice user.id, 1
            for key, value of @zoomCams
                if key is user.id
                    @zoom user.id, undefined
                    return

    newStream : (event, data) =>
        @streams.push data.uid
        video = ($ data.video)
        if data.local? and data.local is true
            video.addClass 'flipH'
        video.addClass 'thumbnailVideo'
        video.attr 'rel', data.uid
        @emitter.trigger 'stream.display', video
        if !data.local?
            @zoom data.uid, video

    changeStreamState : (event, data) =>
        # Data.state = {audio : bool, video : bool}

    # Must set margin-left css propriety when adding a video tag to the page
    # Width is computed using video original size (640 * 480) since css value is wrong at this time
    centerVideoTag : (video) =>
        marginleft = ((do video.height) * 640 / 480) / 2
        video.css 'margin-left', -marginleft
        do video[0].play

    resizeZoomCams : () =>
        cam = ($ '#mainCam')
        x = do cam.width
        y = do cam.height
        n = Object.keys(@zoomCams).length
        px = Math.ceil(Math.sqrt(n * x / y))
        if n is 0
            return
        if Math.floor(px * y / x) * px < n
            sx = y / Math.ceil(px * y / x)
        else
            sx = x / px

        py = Math.ceil(Math.sqrt(n * y/ x))
        if Math.floor(py * x / y) * py < n
            sy = x / Math.ceil(x * py / y)
        else
            sy = y / py
        size = if sx > sy then sx else sy
        for key, li of @zoomCams
            li.css 'width', "#{size}px"
            li.css 'height', "#{size}px"
            @centerVideoTag (li.find 'video')

    zoom : (uid, video) =>
        @detachToMainCam uid, video
        if video?
            @attachToMainCam uid, video

    attachToMainCam : (uid, video) =>
        container = ($ '#mainCam')
        newVideo     = do video.clone
        newVideo[0].volume = video[0].volume
        newVideo.removeClass 'thumbnailVideo'
        do newVideo[0].play
        html = ($ "<li id='zoomcam_#{uid}' class='zoom-cam-wrapper zoom-cam'>
                        <div class='zoom-control index1'>
                            <ul>
                                <li class='closeBtn'><i class='icon-remove'></i></li>
                            </ul>
                        </div>
                    </li>")
        (html.find '.closeBtn').click () =>
            @zoom uid, undefined
        html.append newVideo
        container.append html
        @centerVideoTag newVideo
        @zoomCams[uid] = ($ "li#zoomcam_#{uid}")
        do @resizeZoomCams

    detachToMainCam : (uid, video) =>
        container    = ($ '#mainCam')
        container.removeClass 'hidden'
        @emitter.trigger 'stream.zoom', uid
        for key, value of @zoomCams
            if key is uid
                do value.remove
                delete @zoomCams[uid]
                do @resizeZoomCams
                return

    diaporamaMode     : () =>
        shortcut.add 'Ctrl+Shift+M', () =>
            if @diaporama is off
                @diaporama = on
                for key, value of @zoomCams
                    do value.remove
                    delete @zoomCams[key]
                @diapoTimer = setInterval @autoChangeMainCam, 3000
            else
                @diaporama = off
                clearInterval @diapoTimer

    autoChangeMainCam : () =>
        sidebar = ($ '#feeds')
        mainCam = ($ '#mainCam')
        videos = sidebar.find('video')
        if @diapoIndex isnt 0 and videos.length > 2
            for key, value of @zoomCams
                do value.remove
                oldKey = key
                delete @zoomCams[key]
        if videos.length > 2
            videos.each (index) =>
                if index > 0
                    if @diapoIndex is videos.length
                        uid = ($ videos[1]).attr('rel')
                        @attachToMainCam uid, ($ videos[1])
                        @diapoIndex = 1
                        @zoomCams[uid] = videos[1]
                    else if index > @diapoIndex
                        uid = ($ videos[index]).attr('rel')
                        @diapoIndex = index
                        @attachToMainCam uid, ($ videos[index])
                        @zoomCams[uid] = videos[index]
                        return
        else if videos.length is 2
            if mainCam.find('video').length isnt 1
                uid = ($ videos[1]).attr('rel')
                @attachToMainCam uid, ($ videos[1])
                @diapoIndex = 1


if window?
    window.Camera = Camera
