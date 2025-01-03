local speaker = peripheral.find("speaker")
local chat = peripheral.find("chatter")

local decoder = require("cc.audio.dfpwm").make_decoder()

print("Type your messages and tts will read them.")
while true do
    local message = read()
    message = "Connection terminated. I'm sorry to interrupt you Elizabeth, if you still even remember that name. But I'm afraid you've been misinformed. You are not here to receive a gift, nor have you been called here by the individual you assume. Although you have indeed been called.You have all been called here. Into a labyrinth of sounds and smells, misdirection and misfortune. A labyrinth with no exit, a maze with no prize. You don't even realize that you are trapped. Your lust for blood has driven you in endless circles, chasing the cries of children in some unseen chamber, always seeming so near, yet somehow out of reach.But you will never find them, none of you will. This is where your story ends.And to you, my brave volunteer, who somehow found this job listing not intended for you. Although there was a way out planned for you, I have a feeling that's not what you want. I have a feeling that you are right where you want to be. I am remaining as well, I am nearby.This place will not be remembered, and the memory of everything that started this can finally begin to fade away. As the agony of every tragedy should. And to you monsters trapped in the corridors: Be still and give up your spirits, they don't belong to you.For most of you, I believe there is peace and perhaps more waiting for you after the smoke clears. Although, for one of you, the darkest pit of Hell has opened to swallow you whole, so don't keep the devil waiting, old friend.My daughter, if you can hear me, I knew you would return as well. It's in your nature to protect the innocent. I'm sorry that on that day, the day you were shut out and left to die, no one was there to lift you up into their arms the way you lifted others into yours. And then, what became of you.I should have known you wouldn't be content to disappear, not my daughter. I couldn't save you then, so let me save you now.It's time to rest. For you, and for those you have carried in your arms.This ends for all of us. End communication."


    if #message > 160 then
        local content = {}
        for i = 1, #message, 160 do
            table.insert(content, message:sub(i, i + 160 - 1))
        end
        for i,v in pairs(content) do
            local url = "https://music.madefor.cc/tts?text=" .. textutils.urlEncode(v).."&voice=ru"
            local response, err = http.get { url = url, binary = true }
            if not response then error(err, 0) end
        
            chat.setMessage(v)
            while true do
                local chunk = response.read(16 * 1024)
                if not chunk then break end
            
                local buffer = decoder(chunk)
                while not speaker.playAudio(buffer) do
                    os.pullEvent("speaker_audio_empty")
                end
            end
            local delay = #v * 0.0175
            sleep(delay)
        end
    else
        local url = "https://music.madefor.cc/tts?text=" .. textutils.urlEncode(message)
        local response, err = http.get { url = url, binary = true }
        if not response then error(err, 0) end
    
        while true do
            local chunk = response.read(16 * 1024)
            if not chunk then break end
        
            local buffer = decoder(chunk)
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
        chat.setMessage(message)
        local delay = #message * 0.0175
        sleep(delay)
    end
    chat.clearMessage()

end
