-- By @Reload_LIfe

--
package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
url = require('socket.url')
JSON = require('dkjson')
https = require('ssl.https')
redis_server = require('redis')
redis = redis_server.connect('127.0.0.1', 6379)
--Methods 
if not redis:get('Ruuned1') then
	io.write('Write Bot Token : \n')
	tok = io.read()
	io.write('Sudo : \n')
	ReloadLIfe = io.read()
else
	print ('runned')
end
local token = tok
local link = 'https://api.telegram.org/bot' .. token .. '/'
local sudo = ReloadLIfe


function sendreq(url)
  local dat, res = https.request(url) 
  local tab = JSON.decode(dat) 

  if res ~= 200 then 
    return false, res 
  end 

  if not tab.ok then 
    return false, tab.description 
  end 
  return tab 

end 
local function sendMessage(chat_id, text, mark, reply, markup)
	req = link..'sendMessage?chat_id='..chat_id..'&text='..url.escape(text)
	if mark then
		mark = mark:lower()
		if mark == 'md' or mark == 'markdown' then
			mark = 'Markdown'
			req = req..'&parse_mode='..mark
		elseif mark == 'html' then
			mark = 'HTML'
			req = req..'&parse_mode='..mark
		end
	end
	if reply then
		req = req..'&reply_to_message_id='..reply
	end
	if markup then
		req = req..'&reply_markup='..url.escape(markup)
	end
	sendreq(req)
end
local function sendAudio(chat_id, msg_id, audio, title, performer, duration, caption, markup)
	req = link..'sendAudio?chat_id='..chat_id..'&audio='..url.escape(audio)..'&title='..url.escape(title)..'&performer='..url.escape(performer)..'&duration='..url.escape(duration)

  
	if caption then
		req = req..'&caption='..url.escape(caption)
	end
	if msg_id then
		req = req..'&reply_to_message_id='..msg_id
	end
	if markup then
		req = req..'&reply_markup='..url.escape(markup)
	end
	return sendreq(req)
end

local function sendChatAction(chat_id, action)
	req = link..'sendChatAction?chat_id='..chat_id..'&action='..url.escape(action)
	sendreq(req)
end

local function getUpdates(offset)
  local url = link .. 'getUpdates?timeout=20'
  if offset then
    url = url .. '&offset=' .. offset
  end
  return sendreq(url)
end
--Methods
function Runner(msg)
  if msg then
    if msg.text then
        if msg.chat.type == 'private' then
            if msg.text == '/start' then
              redis:sadd('users:M', msg.from.id)
              sendMessage(msg.chat.id, '> سلام\n خوش اومدی به کمک من میتونی اسم اهنگ هاتو عوض کنی😊\n > رهنما :\n /setname "اسم اهنگ" : \n تغییر نام اهنگ \n Channel : @SPRCPU_Company', 'html', msg.message_id)
            elseif msg.text:match('^/setname "(.*)"') then
              matches = { string.match(msg.text, '/setname "(.*)"') }
              redis:set('user:'..msg.from.id..':Music',matches[1])
              sendMessage(msg.chat.id, '> حالا اهنگ رو بفرست یا فوروارد کن....', 'md', msg.message_id)
            elseif msg.text == '/stats' and msg.from.id == sudo then
              sendMessage(msg.chat.id, '> کاربران : '..(redis:scard('users:M') or 0), 'md', msg.message_id)
            end
        end
    elseif msg.audio then
      if msg.chat.type == 'private' then
        if redis:get('user:'..msg.from.id..':Music') then
         sendAudio(msg.chat.id, msg.message_id, msg.audio.file_id, redis:get('user:'..msg.from.id..':Music'), 'SPR-CPU', msg.audio.duration, 'By @SPRCPU_Company')
        else 
         sendAudio(msg.chat.id, msg.message_id, msg.audio.file_id, 'SPRCPU', 'SPR-CPu', msg.audio.duration, 'By @SPRCPU_Company')
        end
      end
  else
    sendMessage(msg.chat.id, '> دوست عزیز باید اهنگ بفرستی ', 'md', msg.message_id)
	end
  end
end


--
function bot_run()
	local bot_info = "NameChangerBot Runned \n Sudo ".. sudo .. '\nDev : @Reload_Life'
	print(bot_info)
	last_update = last_update or 0
	is_running = true
end
bot_run()
while is_running do 
	local response = getUpdates(last_update+1) 
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			Runner(v.message)
		end
	else
		print("Crashed!!")
	end
end
print('Halted :(')


























