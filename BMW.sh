--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @TshAkETEAM
--]]
serpent = require('serpent')
serp = require 'serpent'.block
http = require("socket.http")
config2 = dofile('libs/serpant.lua') 
https = require("ssl.https")
http.TIMEOUT = 10
lgi = require ('lgi')
TSHAKE=dofile('utils.lua')
json=dofile('json.lua')
JSON = (loadfile  "./libs/dkjson.lua")()
redis = (loadfile "./libs/JSON.lua")()
redis = (loadfile "./libs/redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
tdcli = dofile('tdcli.lua')
notify.init ("Telegram updates")
sudos = dofile('sudo.lua')
chats = {}
day = 86400

  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
  if msg.sender_user_id_ == v then
  var = true
  end
end
  local keko_add_sudo = redis:get('sudoo'..msg.sender_user_id_..''..bot_id)
  if keko_add_sudo then
  var = true
  end
   return var
  end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if admin then
      var = true
   end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	local hashsss =  'bot:vipgp:'..chat_id
    local vip = database:sismember(hashsss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
	 if vip then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if owner then
      var = true
   end
   if admin then
      var = true
   end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end

-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gbanned(user_id)
  local var = false
  local hash = 'bot:gbanned:'
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gmuted(user_id, chat_id)
    local var = false
	local hash = 'bot:gmuted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function get_info(user_id)
  if database:hget('bot:username',user_id) then
    text = '@'..(string.gsub(database:hget('bot:username',user_id), 'false', '') or '')..''
  end
  get_user(user_id)
  return text
  --db:hrem('bot:username',user_id)
end
function get_user(user_id)
  function dl_username(arg, data)
    username = data.username or ''

    --vardump(data)
    database:hset('bot:username',data.id_,data.username_)
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_username, nil)
end
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_vip(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
os.execute('cd .. &&  rm -fr ../.telegram-cli')
os.execute('cd .. &&  rm -rf ../.telegram-cli')
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end

  local function deleteMessagesFromUser(chat_id, user_id, cb, cmd)
    tdcli_function ({
      ID = "DeleteMessagesFromUser",
      chat_id_ = chat_id,
      user_id_ = user_id
    },cb or dl_cb, cmd) 
  end 
os.execute('cd .. &&  rm -rf .telegram-cli')
os.execute('cd .. &&  rm -fr .telegram-cli')
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
if not config2 then 
os.execute('cd .. &&  rm -rf TshAkE')
os.execute('cd .. &&  rm -rf TshAkEapi')
os.execute('cd .. &&  rm -fr TshAkE')
os.execute('cd .. &&  rm -fr TshAkEapi')
print(config2.tss)
 return false end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delmsg(arg,data)
  for k,v in pairs(data.messages_) do
    delete_msg(v.chat_id_,{[0] = v.id_})
  end
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    channel_get_bots(channel,get_bots)
end

  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    -------------* EXPIRE *-----------------
    if not database:get("bot:charge:"..msg.chat_id_) then
     if database:get("bot:enable:"..msg.chat_id_) then
      database:del("bot:enable:"..msg.chat_id_)
      for k,v in pairs(sudo_users) do
      end
      end
    end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '• `ÇáÇíÏí` ??: *'..msg.sender_user_id_..'* \n`ŞãÊ ÈÚãá ÊßÑÇÑ ááÑÓÇÆá ÇáãÍÏÏå` ??\n`æÊã ÍÙÑß ãä ÇáãÌãæÚå` ?', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:warn'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:warn'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:muted:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '• `ÇáÇíÏí` ??: *'..msg.sender_user_id_..'* \n`ŞãÊ ÈÚãá ÊßÑÇÑ ááÑÓÇÆá ÇáãÍÏÏå` ??\n`æÊã ßÊãß İí ÇáãÌãæÚå` ?', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:del'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:del'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
                           send(msg.chat_id_, msg.id_, 1, '• `ÇáÇíÏí` ??: *'..msg.sender_user_id_..'* \n`ŞãÊ ÈÚãá ÊßÑÇÑ ááÑÓÇÆá ÇáãÍÏÏå` ??\n`æÊã ãÓÍ ßá ÑÓÇÆáß` ?', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("Send INLINE KEYBOARD")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("SEND TEXT")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("SEND PHOTO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD TO GROUP")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("JOIN TO GROUP")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("SEND STICKER")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("SEND MUSIC")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("SEND VOICE")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("SEND VIDEO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("SEND GIF")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("SEND LOCATION")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("SEND CONTACT")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_gbanned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
          delete_msg(chat,msgs)
		  return 
end
if database:get('bot:muteall'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end

if database:get('bot:muteallwarn'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáæÓÇÆØ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
        return 
end

if database:get('bot:muteallban'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáæÓÇÆØ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ?\n• <code>Êã ØÑÏß</code> ??", 1, 'html')
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:warn'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, "• `ÇáÇíÏí ` ??: _"..msg.sender_user_id_.."_\n• `ÇáãÚÑİ ` ?? : "..get_info(msg.sender_user_id_).."\n• `ÇáÊËÈíÊ ãŞİæá áÇ ÊÓÊØíÚ ÇáÊËÈíÊ ÍÇáíÇ` ??", 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '• `Şã ÈÇÑÓÇá ÇáãäÔæÑ ãä ÇáŞäÇÉ` ??', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, '• <code>ÚÏÏ ÇáãÔÇåÏÇÊ </code>: ??\n• '..msg.views_..' ', 1, 'html')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:photo:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
		   chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÑ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ?\n• <code>Êã ØÑÏß</code> ??", 1, 'html')

          return 
   end
        if database:get('bot:photo:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÑ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
        end
        end
end
   elseif msg.content_.ID == 'MessageDocument' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:document:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:document:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãáİÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:document:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãáİÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Inline' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:inline:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÇäáÇíä Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:inline:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÇäáÇíä Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:sticker:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãáÕŞÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:sticker:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãáÕŞÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} ??'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} ??'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:contact:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÌåÇÊ ÇáÇÊÕÇá Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:contact:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÌåÇÊ ÇáÇÊÕÇá Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:music:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÇÛÇäí Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:music:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÇÛÇäí Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:voice:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÊíÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:voice:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÊíÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:location:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÔÈßÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:location:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÔÈßÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:video:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáİíÏíæåÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:video:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "<code>ÇíÏíß : </code><code>"..msg.sender_user_id_.."</code>\n<code>ÇáİíÏíæåÇÊ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code>", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:gifs:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÑ ÇáãÊÍÑßå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:gifs:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÕæÑ ÇáãÊÍÑßå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link' and is_mod(msg.sender_user_id_, msg.chat_id_) then if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then 	 local glink = text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") local hash = "bot:group:link"..msg.chat_id_ database:set(hash,glink) 			 send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md') send(msg.chat_id_, 0, 1, '<b>New Group link:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or 
text:match("[Tt].[Mm][Ee]") or
text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
       if database:get('bot:links:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÑæÇÈØ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
  end
       if database:get('bot:links:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÑæÇÈØ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
	end
 end

            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:mute'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
              end
          end 
          
            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam:warn'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:warn'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáßáÇíÔ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
              end
          end 

	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:text:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÏÑÏÔå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:text:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÏÑÏÔå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
end
end
if msg.forward_info_ then
if database:get('bot:forward:ban'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÊæÌíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
	end
   end

if msg.forward_info_ then
if database:get('bot:forward:warn'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÊæÌíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
	end
   end
end
elseif msg_type == 'MSG:Text' then
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:tag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãÚÑİÇÊ <@> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:tag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãÚÑİÇÊ <@> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
 end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:hashtag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÊÇßÇÊ <#> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:hashtag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÊÇßÇÊ <#> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
end

   	if text:match("/") then
      if database:get('bot:cmd:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end 
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
      if database:get('bot:cmd:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÔÇÑÍå </> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
	end 
	      if database:get('bot:cmd:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáÔÇÑÍå </> Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
	end 
	end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:webpage:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãæÇŞÚ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:webpage:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãæÇŞÚ Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
 end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:arabic:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇááÛå ÇáÚÑÈíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:arabic:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇááÛå ÇáÚÑÈíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
 end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
	          if database:get('bot:english:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇááÛå ÇáÇäßáíÒíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
          return 
   end
   
        if database:get('bot:english:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇááÛå ÇáÇäßáíÒíå Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
          return 
   end
     end
    end
   end
  if database:get('bot:cmds'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
  return 
else

if text == 'åáæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• å?óÀ?Ü??á?úÇó?æøò?Çó?Êø? ????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end

if text == 'ÊÔÇßí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• äò?ÜÚøòöÜ??ãò? Êø?İö?ÜÀÖá?ú ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ôáæäßã' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Êø?ãò?Ü?Çó?ãò? æøòÇó?äò?Êø?ÜÀå?óÀ? ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ôáæäß' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?á?úÜÍñ?ãò?Ü??Ï?öÇó?á?úá?úå?óÀ? æøò?Çó?äò?Êø?Üå?óÀ? ?????"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÊãÇã' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Ï?öæøò?ãò? í?óÜ??Çó?Ñ?öÈñ?ö ?????"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'åáÇæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• å?óÀ?ÜÀ?æøò?Çó?Êø? Íñ?Èñ?öÜ?í?ó ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÔõóÜÈñ?öí?óÜßò? ÕöõÜ??Çó?İö?äò? Úøòö Îø?Çó?á?úÊø?ÜÀßò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'åÇí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• å?óÀ?ÜÇó?í?óÜ??Çó?Êø? í?óÜÑ?öæøòÍñ?ÜÀí?ó ????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÈæÊ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Êø?İö?ÜÖÜ?á?ú Íñ?Èñ?öÜÀí?ó ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇÑíÏ ÇßÈá' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÔõóÜæøò?İö?á?úí?ó æøòí?óÜÇó?ßò? Íñ?Ï?öí?óÜÀŞò?å?óÀ? æøòÏ?öÇó?í?óÜ?Íñ? Ñ?öÓñòãò?ÜÀí?ó???????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'áÊÒÍİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Ï?öÚøòöÜæøò?İö?å?óÀ? ÒóğÇó?Íñ?Ü?İö? Úøòö Îø?Çó?á?úÜÊø?ßò? Îø?Üá?úí?ó í?óÓñòÜÀÊø?İö?Çó?Ï?ö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ßáÎÑÇ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Îø?Ü?Ñ?öÇó? í?óÊø?ÜÀÑ?öÓñò Íñ?á?úßò?Ü?ßò? í?óÇó?Îø?Ü?Ñ?öÇó?Çó????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÒÇÍİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÒóğÇó?Íñ?Ü?İö? Úøòö Çó?Îø?Êø?Ü?ßò?¿ ßò?Öí?óÜ?Êø? Úøòöãò?Ñ?ößò? ÌğøöÑ?öÌğøöÜ?İö??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ïí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Îø?á?úí?óäò?Ü?í?ó Çó?Íñ?Èñ?öÜ?ßò? ???"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'İÑÎ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• æøòí?óäò?Ü?å?óÀ?¿ Îø? Çó?Íñ?ÖÜ?Ñ?öå?óÀ? ?????"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÊÚÇáí ÎÇÕ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?å?óÀ?Ü?æøò? ÖÜ?á?ú ÖÜ?á?ú ÓñòÜ?Çó?Íñ?İö? ßò?Èñ?öÜ?Ñ?ö Øöóõãò?ÜÀßò????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇßÑåß' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•Ï?öí?óá?úÜ?å?óÀ? ÔõóÜ?æøò?äò? Çó?Øöóõí?óÜŞò?ßò? äò?Üí?ó ????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇÍÈß' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•Íñ?Èñ?öí?óÈñ?öÜ?í?ó æøòäò?Ü?í?ó å?óÀ?ÜÜãò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÈÇí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• æøòí?óÜ?äò? Ñ?öÇó?í?óÜÀÍñ? Îø?á?úí?óäò?Ü?å?óÀ? ãò?Êø?æøòäò?Óñòí?óÜ?äò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'æÇßİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Èñ?öäò?á?úÎø?Ü?Ñ?öÇó? æøòí?óÜ?äò? æøòÇó?ßò?Ü?İö??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'æíä ÇáãÏíÑ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• á?úí?óÜ?Ôõó ÔõóÊø?Ü?Ñ?öí?óÏ?ö???"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇäÌÈ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÕöõÜ?Çó?Ñ?ö ÓñòÊø?Ü?Çó?Ï?öí?ó???"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÊÍÈäí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ãò?Ü?Çó?Ï?öÑ?öí?ó Çó?İö?ßò?Ü?Ñ?ö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• İö?Ü?Ï?öí?óÊø? ÕöõÎø?Ü?Çó?ãò?ßò?????? "
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• äò?ÜÀÒóğá?ú Úøòöí?óÜäò?ßò? Úøòöí?óÜ?Èñ?ö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÔõóÈñ?öí?óÜ?ßò? ßò?Çó?á?úÜ?Èñ?ö Îø?á?úŞò?Êø?Ü?ßò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• å?óÀ?ÜÇó? Èñ?öÓñò á?úÇó? Ôõóİö?Ü?Êø? Úøòöãò?Êø?Ü?ßò? Çó?á?úÚøòöÜ?æøò?Èñ?öå?óÀ??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Êø?ÚøòöÜ?Çó?á?ú Çó?Ôõóßò?í?óá?úÜ?í?ó å?óÀ?ãò?æøòãò?Ü?ßò? á?úí?óÜÔõó • ÖÇó?í?óÜ?Ìğøö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '????' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Êø?ÚøòöÜ?Çó?á?ú Çó?Ôõóßò?í?óá?úÜ?í?ó å?óÀ?ãò?æøòãò?Ü?ßò? á?úí?óÜÔõó • ÖÇó?í?óÜ?Ìğøö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Ëöúúßò?í?óÜ?á?ú äò?å?óÀ?äò?å?óÀ?äò?å?óÀ?äò?å?óÀ????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ãò?äò?Ü?æøò?Ñ?ö Íñ?Èñ?öÜÚøòöãò?ÜÀÑ?öí?ó?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÕÈÇÍæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÕöõÈñ?öÇó?Íñ?ÜÀßò? ÚøòöÓñòÜÀá?ú í?óÚøòöÓñòÜ?á?ú?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÕÈÇÍ ÇáÎíÑ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÕöõÈñ?öÇó?Íñ?ÜÀßò? ÚøòöÓñòÜÀá?ú í?óÚøòöÓñòÜ?á?ú?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ßİæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?å?óÀ? ßò?İö?Ü?æøò? í?óÈñ?öÀæøò? Çó?á?úÖÜá?úÀæøò?Úøòö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?á?úãò?Øöóõá?úÜ?æøò?Èñ?ö !?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇåÇ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• í?óÈñ?ö Şò?Çó?Èñ?öÜ?á?ú Çó?Ûö?öÔõóÜ?ßò? ÔõóÓñòÇó?á?úİö?Ü?å?óÀ? Íñ?Èñ?ö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÔÓãÌ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?ÓñòÜãò?å?óÀ?Ü?Çó? ÌğøöÚøòöÌğøöÜ?æøò?Úøòöå?óÀ??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÔÓãß' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?Óñòãò?Ü?å?óÀ? ÚøòöÈñ?öÜ?æøò?Óñòí?ó á?úÜæøò?ÓñòÀí?ó???????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ôæİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ÔõóÔõóÜ??æøò?İö? ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ãÓÇÁ ÇáÎíÑ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ãò?ÓñòÜ?Çó?Á Çó?á?úÍñ?Ü?Èñ?ö í?óÍñ?ÀÈñ?öÍñ?ÀÈñ?ö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇáãÏÑÓå' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• á?úÊø?Ìğøöí?óÜ?Èñ?ö Çó?Óñòãò?Ü?å?óÀ? á?úÇó? Çó?ØöóõÜ?Ñ?öÏ?ößò?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ãäæ ÏíÍĞİ ÑÓÇÆáí' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Îø?Ü?Çó?á?úÊø?ÜÀßò? ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇáÈæÊ æÇßİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• á?úÌğøöÜ?ĞóúÈñ?ö Íñ?Èñ?öÜÀí?ó ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÛáÓ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• æøò?ßò? Èñ?öÜ?Óñò ÓñòÜ?æøò?á?úİö?á?úí?ó Çó?á?úÓñòÜ?Çó?á?úİö?å?óÀ? Èñ?öÚøòöÜ?Ï?öí?óäò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÍÇÑÉ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Êø?ÓñòÜÀãò?Øöóõ Óñòãò?Ü?Øöóõ Ûö?öí?óÜ?Ñ?ö í?óÑ?öÍñ?ãò?äò?Ü?å?óÀ? Çó?á?úÇó?ÚøòöÈñ?öÜÇó?Ï?öí?ó æøòí?óäò?ÜÀØöóõí?ó ÚøòöØöóõá?úÜ?å?óÀ? ?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'åååå' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• äò?ÔõóÜ?Çó?á?úá?úå?óÀ? Ï?öÇó?í?óãò?Ü?å?óÀ?????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ååååå' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• äò?ÔõóÜ?Çó?á?úá?úå?óÀ? Ï?öÇó?í?óãò?Ü?å?óÀ?????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '??' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• äò?ÔõóÜ?Çó?á?úá?úå?óÀ? Ï?öÇó?í?óãò?Ü?å?óÀ?????????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'æíä' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Èñ?öÜ??ÃÑ?öÖ Çó?á?úá?úå?óÀ? Çó?á?úÜÀæøòÇó?ÓñòÚøòöÜ?å?óÀ??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ßÇİí áÛæÉ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ßò?Üí?óİö?äò?Ü?å?óÀ? äò?Êø?Ü?å?óÀ? ÔõóÚøòöÜÀá?úí?óßò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'äÇíãíä' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?äò?Ü?í?ó Óñòå?óÀ?ÜÀÑ?öÇó?äò? Çó?Íñ?Ñ?öÓñòÜ?ßò?ãò? ãò?Ü??? Êø?ÜÑ?öÇó?ãò?Ü?Èñ?ö???????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Çßæ ÇÍÏ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• í?ó Úøòöí?óÜäò?Ü?í?ó Çó?äò?ÜÀí?ó ãò?Üæøò?ÌğøöÜ?æøòÏ?ö????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'İÏíÊ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•İö?Ü??Ï?öÇó?ßò?/Ìğøö ËöúúÜ?æøò?á?úÇó?äò? Çó?á?úßò?ÜÑ?öæøò?Èñ?ö???????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Ôßæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ßò?á?úÜÔõóÜ??í?ó ãò?ÜÀÇó?ßò?Ü?æøò Çó?Ñ?öÌğøöÜÚøòö äò?ÜÇó?ãò??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'Çæİ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• å?óÀ?Ü??Çó?í?ó Çó?æøòİö? ãò?äò? í?óÜÇó? äò?Üæøò?Úøòö ÕöõÜÇó?Ñ?öÊø? Çó?á?úÜÓñòÇó?á?úİö?å?óÀ? ãò?Êø?Üäò?ÚøòöÑ?öİö??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇÍÈÌ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•ÌğøöÜ?ĞóúÇó?Èñ?ö í?óÜÑ?öí?óÏ?ö í?óØöóõÜÀßò?Ìğøö?????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ÇäÊÉ ãäæ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• Çó?äò?Ü??í?ó Èñ?öÜæøò?Êø??????"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[Ll][Ee][Aa][Vv][Ee]$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
    
	if text:match("^ãÛÇÏÑå$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ÑİÚ ÇÏãä','setmote')
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÑİÚå ÇÏãä` ??', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÑİÚå ÇÏãä` ??', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as moderator.!</code>'
          else
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÑİÚå ÇÏãä</code> ??'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as moderator._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apmd[2]..'* `Êã ÑİÚå ÇÏãä` ??', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ÊäÒíá ÇÏãä','remmote')
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÊäÒíáå ãä ÇáÇÏãäíå` ??', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÊäÒíáå ãä ÇáÇÏãäíå` ??', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÊäÒíáå ãä ÇáÇÏãäíå</code> ??'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apmd[2]..'* `Êã ÊäÒíáå ãä ÇáÇÏãäíå` ??', 1, 'md')
  end
  end
  -----------------------------------------------------------------------------------------------
if msg.content_.entities_ then
if msg.content_.entities_[0] then
if msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityUrl" or msg.content_.entities_[0].ID == "MessageEntityTextUrl" then
if database:get('bot:markdown:mute'..msg.chat_id_) then
if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  delete_msg(msg.chat_id_, {[0] = msg.id_})
end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
 if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
delete_msg(msg.chat_id_, {[0] = msg.id_})
end
end
end
end
if database:get('bot:markdown:ban'..msg.chat_id_) then
if not is_vip(msg.sender_user_id_, msg.chat_id_) then
delete_msg(msg.chat_id_, {[0] = msg.id_})
chat_kick(msg.chat_id_, msg.sender_user_id_)
  send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãÇÑßÏæä Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ??\n• <code>Êã ØÑÏß</code> ?", 1, 'html')
end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
 if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
delete_msg(msg.chat_id_, {[0] = msg.id_})
end
end
end
end
if database:get('bot:markdown:warn'..msg.chat_id_) then
if not is_vip(msg.sender_user_id_, msg.chat_id_) then
delete_msg(msg.chat_id_, {[0] = msg.id_})
  send(msg.chat_id_, 0, 1, "• <code>ÇáÇíÏí ?? : </code><code>"..msg.sender_user_id_.."</code>\n• <code>ÇáãÇÑßÏæä Êã ŞİáåÇ ããäæÚ ÇÑÓÇáåÇ</code> ???", 1, 'html')
end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
 if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
delete_msg(msg.chat_id_, {[0] = msg.id_})
end
end
end
end
end
end
end
  -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ÑİÚ ÚÖæ ããíÒ','setvip')
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÑİÚå ÚÖæ ããíÒ` ??', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÑİÚå ÚÖæ ããíÒ` ??', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:vipgp:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as vip.!</code>'
          else
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÑİÚå ÚÖæ ããíÒ</code> ??'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) (%d+)$")} 	
	        database:sadd('bot:vipgp:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as vip._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apmd[2]..'* `Êã ÑİÚå ÚÖæ ããíÒ` ??', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('ÊäÒíá ÚÖæ ããíÒ','remvip')
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted vip._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÊäÒíáå ãä ÇáÇÚÖÇÁ ÇáããíÒíä` ??', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted vip._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÊäÒíáå ãä ÇáÇÚÖÇÁ ÇáããíÒíä` ??', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted vip</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÊäÒíáå ãä ÇáÇÚÖÇÁ ÇáããíÒíä</code> ??'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted vip._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apmd[2]..'* `Êã ÊäÒíáå ãä ÇáÇÚÖÇÁ ÇáããíÒíä` ??', 1, 'md')
  end
  end
  
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÍÙÑ','Ban')
	if text:match("^[Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Banned._', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÍÙÑå` ??', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Banned._', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÍÙÑå` ??', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) @(.*)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Banned.!</b>'
else
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÍÙÑå</code> ??'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) (%d+)$")}
	if is_mod(apba[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, apba[2])
		 chat_kick(msg.chat_id_, apba[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Banned._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apba[2]..'* `Êã ÍÙÑå` ??', 1, 'md')
  	end
	end
end
  ----------------------------------------------unban--------------------------------------------
          local text = msg.content_.text_:gsub('ÇáÛÇÁ ÍÙÑ','unban')
  	if text:match("^[Uu][Nn][Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success) 
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Banned._', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÇáÛÇÁ ÍÙÑå` ??', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Unbanned._', 1, 'md')
       else
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÇáÛÇÁ ÍÙÑå` ??', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) @(.*)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Unbanned.!</b>'
      else
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÇáÛÇÁ ÍÙÑå</code> ??'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, apba[2])
        if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Unbanned._', 1, 'md')
else
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apba[2]..'* `Êã ÇáÛÇÁ ÍÙÑå` ??', 1, 'md')
end
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÍĞİ Çáßá','delall')
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function delall_by_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍĞİ ÑÓÇÆá ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
else
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..result.sender_user_id_..'* _Has been deleted!!_', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÍĞİ ßá ÑÓÇÆáå` ??', 1, 'md')
end
		     del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
		local ass = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) (%d+)$")} 
	if is_mod(ass[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍĞİ ÑÓÇÆá ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
else
	 		     del_all_msgs(msg.chat_id_, ass[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..ass[2]..'* _Has been deleted!!_', 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..ass[2]..'* `Êã ÍĞİ ßá ÑÓÇÆáå` ??', 1, 'md')
end    end
	end
 -----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apbll = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) @(.*)$")} 
	function delall_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍĞİ ÑÓÇÆá ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
return false
    end
		 		     del_all_msgs(msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>All Msg From user</b> <code>'..result.id_..'</code> <b>Deleted!</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÍĞİ ßá ÑÓÇÆáå</code> ??'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apbll[2],delall_by_username)
    end
  -----------------------------------------banall--------------------------------------------------
          local text = msg.content_.text_:gsub('ÍÙÑ ÚÇã','banall')
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
	if is_admin(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇÏãäíå ÇáÈæÊ æÇáãØæÑíä ÚÇã ???', 1, 'md')
end
    else
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Banned !</b>'
                else
                  texts = '• <code>ÇáÚÖæ </code>'..result.sender_user_id_..'<code> Êã ÍÙÑå ÚÇã</code> ??'
end
end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function gban_by_username(extra, result, success)
              if result.id_ then
         	if is_admin(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇÏãäíå ÇáÈæÊ æÇáãØæÑíä ÚÇã ???', 1, 'md')
end
  else
              local hash = 'bot:gbanned:'
                if database:get('lang:gp:'..msg.chat_id_) then
                texts = '<b>User :</b> <code>'..result.id_..'</code> <b> Has been Globally Banned !</b>'
              else 
                texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÍÙÑå ÚÇã</code> ??'
end
                database:sadd(hash, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else
                  texts = '<code>ÎØÇ </code>??'
                end
            end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apbll[2],gban_by_username)
          end
          
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
  local hash = 'bot:gbanned:'
	if is_admin(apbll[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ÍÙÑ ÇÏãäíå ÇáÈæÊ æÇáãØæÑíä ÚÇã ???', 1, 'md')
end
    else
	        database:sadd(hash, apbll[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apbll[2]..'* _Has been Globally Banned _', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apbll[2]..'* `Êã ÍÙÑå ÚÇã` ??', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÇáÛÇÁ ÇáÚÇã','unbanall')
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Unbanned !</b>'
             else
                  texts =  '• <code>ÇáÚÖæ '..result.sender_user_id_..' Êã ÇáÛÇÁ ÍÙÑå ãä ÇáÚÇã </code> ??'
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apid = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function ungban_by_username(extra, result, success)
              local hash = 'bot:gbanned:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                 texts = '<b>User :</b> '..result.id_..' <b>Has been Globally Unbanned !</b>'
                else
                texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÇáÛÇÁ ÍÙÑå ãä ÇáÚÇã</code> ??'
                end
                database:srem(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else 
                  texts = '<code>ÎØÇ </code>??'
                        end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apid[2],ungban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
            local hash = 'bot:gbanned:'
              database:srem(hash, apbll[2])
              if database:get('lang:gp:'..msg.chat_id_) then
              texts = '<b>User :</b> '..apbll[2]..' <b>Has been Globally Unbanned !</b>'
            else 
                texts = '• <code>ÇáÚÖæ </code>'..apbll[2]..'<code> Êã ÇáÛÇÁ ÍÙÑå ãä ÇáÚÇã</code> ??'
end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ßÊã','silent')
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• `áÇ ÊÓÊØíÚ ßÊã ÇáÇÏãäíå æÇáãÏÑÇÁ` ???', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already silent._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ßÊãå` ??', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _silent_', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ßÊãå` ??', 1, 'md')
end
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• `áÇ ÊÓÊØíÚ ßÊã ÇáÇÏãäíå æÇáãÏÑÇÁ` ???', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>silent</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ßÊãå</code> ??'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")}
	if is_mod(apsi[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• `áÇ ÊÓÊØíÚ ßÊã ÇáÇÏãäíå æÇáãÏÑÇÁ` ???', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _silent_', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apsi[2]..'* `Êã ßÊãå` ??', 1, 'md')
end
	end
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÇáÛÇÁ ßÊã','unsilent')
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not silent._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÇáÛÇÁ ßÊãå` ??', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _unsilent_', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÇáÛÇÁ ßÊãå` ??', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>unsilent.!</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÇáÛÇÁ ßÊãå</code> ??'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _unsilent_', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apsi[2]..'* `Êã ÇáÛÇÁ ßÊãå` ??', 1, 'md')
end
  end
    -----------------------------------------------------------------------------------------------
    local text = msg.content_.text_:gsub('ØÑÏ','kick')
  if text:match("^[Kk][Ii][Cc][Kk]$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `áÇ ÊÓÊØíÚ ØÑÏ ÇáÇÏãäíå æÇáãÏÑÇÁ` ???', 1, 'md')
end
  else
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Kicked.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` '..result.sender_user_id_..' `Êã ØÑÏå` ??', 1, 'md')
end
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
  end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) @(.*)$")} 
	function kick_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ØÑÏ ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
    else
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Kicked.!</b>'
else
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ØÑÏå</code> ??'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apki[2],kick_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) (%d+)$")}
	if is_mod(apki[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '• áÇ ÊÓÊØíÚ ØÑÏ ÇáÇÏãäíå æÇáãÏÑÇÁ ???', 1, 'md')
end
    else
		 chat_kick(msg.chat_id_, apki[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apki[2]..'* _Kicked._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apki[2]..'* `Êã ØÑÏå` ??', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
 local text = msg.content_.text_:gsub('ÇÖÇİå','invite')
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee]$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
   function inv_reply(extra, result, success)
    add_user(result.chat_id_, result.sender_user_id_, 5)
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Add it.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` '..result.sender_user_id_..' `Êã ÇÖÇİÊå ááãÌãæÚå` ??', 1, 'md')
   end
   end
    getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
   end
          -----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] @(.*)$") and is_sudo(msg) then
    local apss = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) @(.*)$")}
    function invite_by_username(extra, result, success)
     if result.id_ then
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Add it!</b>'
else
            texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÇÖÇİÊå ááãÌãæÚå</code> ??'
end
    add_user(msg.chat_id_, result.id_, 5)
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
            texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
    resolve_username(apss[2],invite_by_username)
 end
        -----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] (%d+)$") and is_sudo(msg) then
      local apee = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) (%d+)$")}
      add_user(msg.chat_id_, apee[2], 5)
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apee[2]..'* _Add it._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apee[2]..'* `Êã ÇÖÇİÊå ááãÌãæÚå` ??', 1, 'md')
  	end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÑİÚ ãÏíÑ','setowner')
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Owner._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÑİÚå ãÏíÑ` ??', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Promoted as Group Owner._', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÑİÚå ãÏíÑ` ??', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Promoted as Group Owner.!</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÑİÚå ãÏíÑ</code> ??'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, apow[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Promoted as Group Owner._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apow[2]..'* `Êã ÑİÚå ãÏíÑ` ??', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÊäÒíá ãÏíÑ','remowner')
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Owner._', 1, 'md')
    else 
send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÊäÒíáå ãä ÇáãÏÑÇÁ` ??', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from ownerlist._', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÊäÒíáå ãä ÇáãÏÑÇÁ` ??', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	local hash = 'bot:owners:'..msg.chat_id_
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from ownerlist</b>'
     else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÊäÒíáå ãä ÇáãÏÑÇÁ</code> ??'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
         database:srem(hash, apow[2])
	     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Removed from ownerlist._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..apow[2]..'* `Êã ÊäÒíáå ãä ÇáãÏÑÇÁ` ??', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
	          local text = msg.content_.text_:gsub('ÑİÚ ÇÏãä ááÈæÊ','setadmin')
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:' 
	if database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÑİÚå ÇÏãä ááÈæÊ` ??', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Added to admins._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÑİÚå ÇÏãä ááÈæÊ` ??', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Added to admins.!</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÑİÚå ÇÏãä ááÈæÊ</code> ??'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
	        database:sadd('bot:admins:', ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* _Added to admins._', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..ap[2]..'* `Êã ÑİÚå ÇÏãä ááÈæÊ` ??', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÊäÒíá ÇÏãä ááÈæÊ','remadmin')
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `ÈÇáİÚá Êã ÊäÒíáå ãä ÇÏãäíå ÇáÈæÊ` ??', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from Admins!._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..result.sender_user_id_..'* `Êã ÊäÒíáå ãä ÇÏãäíå ÇáÈæÊ` ??', 1, 'md')

end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from Admins!</b>'
          else 
                        texts = '• <code>ÇáÚÖæ </code>'..result.id_..'<code> Êã ÊäÒíáå ãä ÇÏãäíå ÇáÈæÊ</code> ??'
end
          else 
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>ÎØÇ </code>??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
         database:srem(hash, ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* Removed from Admins!_', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '• `ÇáÚÖæ` *'..ap[2]..'* `Êã ÊäÒíáå ãä ÇÏãäíå ÇáÈæÊ` ??', 1, 'md')
end
    end 
	-----------------------------------------------------------------------------------------------
	if text:match("^[Mm][Oo][Dd][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáÇÏãäíå$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Mod List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáÇÏãäíå </code>?? :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ÇÏãäíå</code> ??"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

	if text:match("^[Vv][Ii][Pp][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáÇÚÖÇÁ ÇáããíÒíä") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:vipgp:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Vip List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáÇÚÖÇÁ ÇáããíÒíä </code>?? :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Vip List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ÇÚÖÇÁ ããíÒíä</code> ??"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end

	if text:match("^[Bb][Aa][Dd][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ŞÇÆãå ÇáãäÚ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>bad List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáßáãÇÊ ÇáããäæÚå </code>?? :\n\n"
  end    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>bad List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ßáãÇÊ ããäæÚå</code> ??"
end
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end 
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáãßÊæãíä$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Silent List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáãßÊæãíä </code>?? :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ãßÊæãíä</code> ??"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Oo][Ww][Nn][Ee][Rr][Ss]$") and is_sudo(msg) or text:match("^[Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^ÇáãÏÑÇÁ$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>owner List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáãÏÑÇÁ </code>?? :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>owner List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ãÏÑÇÁ</code> ??"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáãÍÙæÑíä$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>ban List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáãÍÙæÑíä </code>?? :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>ban List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ãÍÙæÑíä</code> ??"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

  if msg.content_.text_:match("^[Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or msg.content_.text_:match("^ŞÇÆãå ÇáÚÇã$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:gbanned:'
    local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Gban List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇáÍÙÑ ÇáÚÇã </code>?? :\n\n"
end	
for k,v in pairs(list) do
    local user_info = database:hgetall('user:'..v)
    if user_info and user_info.username then
    local username = user_info.username
      text = text..k.." - @"..username.." ["..v.."]\n"
      else
      text = text..k.." - "..v.."\n"
          end
end
            if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Gban List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ãÍÙæÑíä ÚÇã</code> ??"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Aa][Dd][Mm][Ii][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ÇÏãäíå ÇáÈæÊ$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Admin List:</b>\n\n"
else 
  text = "• <code>ŞÇÆãå ÇÏãäíå ÇáÈæÊ </code>?? :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Admin List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ÇÏãäíå ááÈæÊ</code> ??"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Dd]$") or text:match("^ÇíÏí$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "`"..result.sender_user_id_.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÇíÏí','id')
    if text:match("^[Ii][Dd] @(.*)$") then
	local ap = {string.match(text, "^([Ii][Dd]) @(.*)$")} 
	function id_by_username(extra, result, success)
	if result.id_ then
            texts = '<code>'..result.id_..'</code>'
          else 
           if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
            texts = '<code>ÎØÇ </code> ??'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],id_by_username)
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÌáÈ ÕæÑå','getpro')
    if text:match("^getpro (%d+)$") and msg.reply_to_message_id_ == 0  then
		local pronumb = {string.match(text, "^(getpro) (%d+)$")} 
local function gpro(extra, result, success)
--vardump(result)
   if pronumb[2] == '1' then
   if result.photos_[0] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '2' then
   if result.photos_[1] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 2 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 2 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '3' then
   if result.photos_[2] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 3 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 3 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '4' then
      if result.photos_[3] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 4 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 4 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '5' then
   if result.photos_[4] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 5 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 5 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '6' then
   if result.photos_[5] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 6 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 6 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '7' then
   if result.photos_[6] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 7 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 7 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '8' then
   if result.photos_[7] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 8 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 8 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '9' then
   if result.photos_[8] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 9 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 9 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
   elseif pronumb[2] == '10' then
   if result.photos_[9] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
   else
                     if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "_You Have'nt 10 Profile Photo!!_", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ Êãáß ÕæÑå 10 İí ÍÓÇÈß` ??", 1, 'md')
end
   end
 else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "• `áÇ ÇÓÊØíÚ ÌáÈ ÇßËÑ ãä 10 ÕæÑ` ??", 1, 'md')
end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = pronumb[2]
  }, gpro, nil)
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('æÖÚ ÊßÑÇÑ ÈÇáØÑÏ','flood ban')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
else
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[2]* Çáì [_99999_]` ??', 1, 'md')
end
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodmax[2]..'*', 1, 'md')
        else
send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáÊßÑÇÑ ÈÇáØÑÏ ááÚÏÏ` ??? : *'..floodmax[2]..'*', 1, 'md')
end
	end
end

          local text = msg.content_.text_:gsub('æÖÚ ÊßÑÇÑ ÈÇáßÊã','flood mute')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[2]* Çáì [_99999_]` ??', 1, 'md')
end
	else
    database:set('flood:max:warn'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood Warn has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáÊßÑÇÑ ÈÇáßÊã ááÚÏÏ` ??? : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('æÖÚ ÊßÑÇÑ ÈÇáãÓÍ','flood del')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[2]* Çáì [_99999_]` ??', 1, 'md')
end
	else
    database:set('flood:max:del'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood delete has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáÊßÑÇÑ ÈÇáãÓÍ ááÚÏÏ` ??? : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('æÖÚ ßáÇíÔ ÈÇáãÓÍ','spam del')
if text:match("^[Ss][Pp][Aa][Mm] [Dd][Ee][Ll] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Dd][Ee][Ll]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[40]* Çáì [_99999_]` ??', 1, 'md')
end
 else
database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáßáíÔå ÈÇáãÓÍ ááÚÏÏ` ??? : *'..sensspam[2]..'*', 1, 'md')
end
end
end
          local text = msg.content_.text_:gsub('æÖÚ ßáÇíÔ ÈÇáÊÍĞíÑ','spam warn')
if text:match("^[Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[40]* Çáì [_99999_]` ??', 1, 'md')
end
 else
database:set('bot:sens:spam:warn'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam Warn has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáßáíÔå ÈÇáÊÍĞíÑ ááÚÏÏ` ??? : *'..sensspam[2]..'*', 1, 'md')
end
end
end

	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('æÖÚ Òãä ÇáÊßÑÇÑ','flood time')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee]) (%d+)$")} 
	if tonumber(floodt[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '• `ÖÚ ÚÏÏ ãä  *[1]* Çáì [_99999_]` ??', 1, 'md')
end
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodt[2]..'*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ Òãä ÇáÊßÑÇÑ ááÚÏÏ ` ??? : *'..floodt[2]..'*', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^æÖÚ ÑÇÈØ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         database:set("bot:group:link"..msg.chat_id_, 'Waiting For Link!\nPls Send Group Link')
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Please Send Group Link Now!*', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '• `Şã ÈÇÑÓÇá ÇáÑÇÈØ áíÊã ÍİÙå` ??', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^ÇáÑÇÈØ$") then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '<b>Group link:</b>\n'..link, 1, 'html')
       else 
                  send(msg.chat_id_, msg.id_, 1, '• <code>ÑÇÈØ ÇáãÌãæÚå ?? :</code>\n'..link, 1, 'html')
end
	  else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*There is not link set yet. Please add one by #setlink .*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '• `áã íÊã ÍİÙ ÑÇÈØ ÇÑÓá [ æÖÚ ÑÇÈØ ] áÍİÙ ÑÇÈØ ÌÏíÏ` ??', 1, 'md')
end
	  end
 	end
	
	if text:match("^[Ww][Ll][Cc] [Oo][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Enabled* In This Supergroup.', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^[Ww][Ll][Cc] [Oo][Ff][Ff]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Disabled* In This Supergroup.', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end
	
	if text:match("^ÊİÚíá ÇáÊÑÍíÈ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÊİÚíá ÇáÊÑÍíÈ ` ??', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^ÊÚØíá ÇáÊÑÍíÈ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚØíá ÇáÊÑÍíÈ ` ??', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end

	if text:match("^[Ss][Ee][Tt] [Ww][Ll][Cc] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^([Ss][Ee][Tt] [Ww][Ll][Cc]) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Saved!*\nWlc Text:\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end
	
	if text:match("^æÖÚ ÊÑÍíÈ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^(æÖÚ ÊÑÍíÈ) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇáÊÑÍíÈ` ??? :\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end

          local text = msg.content_.text_:gsub('ÍĞİ ÇáÊÑÍíÈ','del wlc')
	if text:match("^[Dd][Ee][Ll] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '• `Êã ÍĞİ ÇáÊÑÍíÈ` ???', 1, 'md')
end
		 database:del('welcome:'..msg.chat_id_)
	end
	
          local text = msg.content_.text_:gsub('ÌáÈ ÇáÊÑÍíÈ','get wlc')
	if text:match("^[Gg][Ee][Tt] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local wel = database:get('welcome:'..msg.chat_id_)
	if wel then
         send(msg.chat_id_, msg.id_, 1, '• `ÇáÊÑÍíÈ ` ?? :'..wel, 1, 'md')
    else 
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'Welcome msg not saved!', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '• `áã íÊã æÖÚ ÊÑÍíÈ ááãÌãæÚå` ??', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ãäÚ','bad')
	if text:match("^[Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local filters = {string.match(text, "^([Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "*New Word baded!*\n--> `"..name.."`", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, "• `"..name.."` `Êã ÇÖÇİÊåÇ áŞÇÆãå ÇáãäÚ` ??", 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÇáÛÇÁ ãäÚ','unbad')
	if text:match("^[Uu][Nn][Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local rws = {string.match(text, "^([Uu][Nn][Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "`"..rws[2].."` *Removed From baded List!*", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, " • "..rws[2].."` Êã ÍĞİåÇ ãä ŞÇÆãå ÇáãäÚ` ???", 1, 'md')
end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÇĞÇÚå','bc')
	if text:match("^bc (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^(bc) (.*)$")} 
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'html')
  end
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Done*\n_Your Msg Send to_ `'..gps..'` _Groups_', 1, 'md')
                   else
                     send(msg.chat_id_, msg.id_, 1, '• `Êã äÔÑ ÇáÑÓÇáå İí` `'..gps..'` `ãÌãæÚå` ??', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Gg][Rr][Oo][Uu][Pp][Ss]$") and is_admin(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáßÑæÈÇÊ$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Groups :* `'..gps..'`', 1, 'md')
                 else
                   send(msg.chat_id_, msg.id_, 1, '• `ÚÏÏ ÇáßÑæÈÇÊ åí ?? :` *'..gps..'*', 1, 'md')
end
	end
	
if  text:match("^[Mm][Ss][Gg]$") or text:match("^ÑÓÇÆáí$") and msg.reply_to_message_id_ == 0  then
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*Msgs : * `"..user_msgs.."`", 1, 'md')
      else 
        end
    else 
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "• `ÚÏÏ ÑÓÇÆáß åí ?? :` *"..user_msgs.."*", 1, 'md')
      else 
        end
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^Şİá (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEPT = {string.match(text, "^(Şİá) (.*)$")} 
    if lockpt[2] == "edit"and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊÚÏíá" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊÚÏíá `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
                database:set('editmsg'..msg.chat_id_,'delmsg')
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *locked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊÚÏíá` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
              end
            end
   if lockpt[2] == "bots" or TSHAKEPT[2] == "ÇáÈæÊÇÊ" then
              if not database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÈæÊÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
                end
                database:set('bot:bots:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÈæÊÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊßÑÇÑ ÈÇáØÑÏ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `Şİá ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
                  end
                database:del('anti-flood:'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊßÑÇÑ ÈÇáßÊã" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `Şİá ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáßÊã `??', 1, 'md')
                  end
                database:del('anti-flood:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáßÊã` ??', 1, 'md')
                end
              end
          end
            	  if lockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊßÑÇÑ ÈÇáãÓÍ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `Şİá ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
                  end
                database:del('anti-flood:del'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊËÈíÊ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊËÈíÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
                end
                database:set('bot:pin:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊËÈíÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "ÇáÊËÈíÊ ÈÇáÊÍĞíÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊËÈíÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
                database:set('bot:pin:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊËÈíÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
              end
            end
          end
          
	-----------------------------------------------------------------------------------------------
	
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^İÊÍ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEUN = {string.match(text, "^(İÊÍ) (.*)$")} 
                if unlockpt[2] == "edit" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊÚÏíá" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊÚÏíá `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
                end
                database:del('editmsg'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *Unlocked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊÚÏíá` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "bots" or TSHAKEUN[2] == "ÇáÈæÊÇÊ" then
              if database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÈæÊÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
                end
                database:del('bot:bots:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÈæÊÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊßÑÇÑ ÈÇáØÑÏ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
                  end
                   database:set('anti-flood:'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊßÑÇÑ ÈÇáßÊã" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáßÊã `??', 1, 'md')
                  end
                   database:set('anti-flood:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáßÊã` ??', 1, 'md')
                end
              end
          end
            	  if unlockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊßÑÇÑ ÈÇáãÓÍ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊßÑÇÑ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
                  end
                   database:set('anti-flood:del'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊßÑÇÑ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊËÈíÊ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊËÈíÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
                end
                database:del('bot:pin:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊËÈíÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "ÇáÊËÈíÊ ÈÇáÊÍĞíÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *Unlocked*", 1, 'md')
                else
                send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊËÈíÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
                end
                database:del('bot:pin:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊËÈíÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
                end
              end
            end
              end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('Şİá Çáßá ÈÇáËæÇäí','lock all s')
  	if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Group muted for_ *'..mutept[1]..'* _seconds!_', 1, 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`• Êã Şİá ßá ÇáæÓÇÆØ áãÏÉ` "..mutept[1].." `ËÇäíå` ???", 'md')
end
	end

          local text = msg.content_.text_:gsub('Şİá Çáßá ÈÇáÓÇÚå','lock all h')
    if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh]  (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh] (%d+)$")}
        local hour = string.gsub(mutept[1], 'h', '')
        local num1 = tonumber(hour) * 3600
        local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
                if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`• Êã Şİá ßá ÇáæÓÇÆØ áãÏÉ` "..mutept[1].." `ÓÇÚå` ???", 'md')
end
     end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^Şİá (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKE = {string.match(text, "^(Şİá) (.*)$")} 
      if mutept[2] == "all" or TSHAKE[2] == "Çáßá" then
	  if not database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:muteall'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ßá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "all warn" or TSHAKE[2] == "Çáßá ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:muteallwarn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ßá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "all ban" or TSHAKE[2] == "Çáßá ÈÇáØÑÏ" then
	  if not database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:muteallban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ßá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "text" or TSHAKE[2] == "ÇáÏÑÏÔå" then
	  if not database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:text:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "text ban" or TSHAKE[2] == "ÇáÏÑÏÔå ÈÇáØÑÏ" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:text:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "text warn" or TSHAKE[2] == "ÇáÏÑÏÔå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:text:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline" or TSHAKE[2] == "ÇáÇäáÇíä" then
	  if not database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:inline:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline ban" or TSHAKE[2] == "ÇáÇäáÇíä ÈÇáØÑÏ" then
	  if not database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:inline:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline warn" or TSHAKE[2] == "ÇáÇäáÇíä ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:inline:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo" or TSHAKE[2] == "ÇáÕæÑ" then
	  if not database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:photo:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo ban" or TSHAKE[2] == "ÇáÕæÑ ÈÇáØÑÏ" then
	  if not database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:photo:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo warn" or TSHAKE[2] == "ÇáÕæÑ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:photo:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "video" or TSHAKE[2] == "ÇáİíÏíæ" then
	  if not database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:video:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "video ban" or TSHAKE[2] == "ÇáİíÏíæ ÈÇáØÑÏ" then
	  if not database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:video:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "video warn" or TSHAKE[2] == "ÇáİíÏíæ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:video:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif" or TSHAKE[2] == "ÇáãÊÍÑßå" then
	  if not database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:gifs:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif ban" or TSHAKE[2] == "ÇáãÊÍÑßå ÈÇáØÑÏ" then
	  if not database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:gifs:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif warn" or TSHAKE[2] == "ÇáãÊÍÑßå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:gifs:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "music" or TSHAKE[2] == "ÇáÇÛÇäí" then
	  if not database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:music:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "music ban" or TSHAKE[2] == "ÇáÇÛÇäí ÈÇáØÑÏ" then
	  if not database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:music:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "music warn" or TSHAKE[2] == "ÇáÇÛÇäí ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:music:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice" or TSHAKE[2] == "ÇáÕæÊ" then
	  if not database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:voice:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice ban" or TSHAKE[2] == "ÇáÕæÊ ÈÇáØÑÏ" then
	  if not database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:voice:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice warn" or TSHAKE[2] == "ÇáÕæÊ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:voice:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "links" or TSHAKE[2] == "ÇáÑæÇÈØ" then
	  if not database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:links:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "links ban" or TSHAKE[2] == "ÇáÑæÇÈØ ÈÇáØÑÏ" then
	  if not database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:links:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "links warn" or TSHAKE[2] == "ÇáÑæÇÈØ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:links:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "location" or TSHAKE[2] == "ÇáÔÈßÇÊ" then
	  if not database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:location:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "location ban" or TSHAKE[2] == "ÇáÔÈßÇÊ ÈÇáØÑÏ" then
	  if not database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:location:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "location warn" or TSHAKE[2] == "ÇáÔÈßÇÊ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:location:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag" or TSHAKE[2] == "ÇáãÚÑİ" then
	  if not database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:tag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag ban" or TSHAKE[2] == "ÇáãÚÑİ ÈÇáØÑÏ" then
	  if not database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:tag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag warn" or TSHAKE[2] == "ÇáãÚÑİ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:tag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag" or TSHAKE[2] == "ÇáÊÇß" then
	  if not database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:hashtag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag ban" or TSHAKE[2] == "ÇáÊÇß ÈÇáØÑÏ" then
	  if not database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:hashtag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag warn" or TSHAKE[2] == "ÇáÊÇß ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:hashtag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact" or TSHAKE[2] == "ÇáÌåÇÊ" then
	  if not database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:contact:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact ban" or TSHAKE[2] == "ÇáÌåÇÊ ÈÇáØÑÏ" then
	  if not database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:contact:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact warn" or TSHAKE[2] == "ÇáÌåÇÊ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:contact:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage" or TSHAKE[2] == "ÇáãæÇŞÚ" then
	  if not database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:webpage:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage ban" or TSHAKE[2] == "ÇáãæÇŞÚ ÈÇáØÑÏ" then
	  if not database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:webpage:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage warn" or TSHAKE[2] == "ÇáãæÇŞÚ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:webpage:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
    end
      if mutept[2] == "arabic" or TSHAKE[2] == "ÇáÚÑÈíå" then
	  if not database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:arabic:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic ban" or TSHAKE[2] == "ÇáÚÑÈíå ÈÇáØÑÏ" then
	  if not database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:arabic:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic warn" or TSHAKE[2] == "ÇáÚÑÈíå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:arabic:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "english" or TSHAKE[2] == "ÇáÇäßáíÒíå" then
	  if not database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:english:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "english ban" or TSHAKE[2] == "ÇáÇäßáíÒíå ÈÇáØÑÏ" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:english:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "english warn" or TSHAKE[2] == "ÇáÇäßáíÒíå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:english:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam del" or TSHAKE[2] == "ÇáßáÇíÔ" then
	  if not database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáßáÇíÔ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:spam:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáßáÇíÔ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam warn" or TSHAKE[2] == "ÇáßáÇíÔ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáßáÇíÔ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:spam:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáßáÇíÔ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker" or TSHAKE[2] == "ÇáãáÕŞÇÊ" then
	  if not database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:sticker:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker ban" or TSHAKE[2] == "ÇáãáÕŞÇÊ ÈÇáØÑÏ" then
	  if not database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:sticker:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker warn" or TSHAKE[2] == "ÇáãáÕŞÇÊ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:sticker:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
    end
      if mutept[2] == "file" or TSHAKE[2] == "ÇáãáİÇÊ" then
	  if not database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:document:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "file ban" or TSHAKE[2] == "ÇáãáİÇÊ ÈÇáØÑÏ" then
	  if not database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:document:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "file warn" or TSHAKE[2] == "ÇáãáİÇÊ ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:document:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
  end
  
      if mutept[2] == "markdown" or TSHAKE[2] == "ÇáãÇÑßÏæä" then
	  if not database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:markdown:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown ban" or TSHAKE[2] == "ÇáãÇÑßÏæä ÈÇáØÑÏ" then
	  if not database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:markdown:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown warn" or TSHAKE[2] == "ÇáãÇÑßÏæä ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:markdown:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
    end
    
	  if mutept[2] == "service" or TSHAKE[2] == "ÇáÇÔÚÇÑÇÊ" then
	  if not database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÇÔÚÇÑÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:tgservice:mute'..msg.chat_id_,true)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÇÔÚÇÑÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd" or TSHAKE[2] == "ÇáÊæÌíå" then
	  if not database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:forward:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd ban" or TSHAKE[2] == "ÇáÊæÌíå ÈÇáØÑÏ" then
	  if not database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:forward:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd warn" or TSHAKE[2] == "ÇáÊæÌíå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:forward:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd" or TSHAKE[2] == "ÇáÔÇÑÍå" then
	  if not database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
         database:set('bot:cmd:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd ban" or TSHAKE[2] == "ÇáÔÇÑÍå ÈÇáØÑÏ" then
	  if not database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
         database:set('bot:cmd:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd warn" or TSHAKE[2] == "ÇáÔÇÑÍå ÈÇáÊÍĞíÑ" then
	  if not database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã` ?? `Şİá ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
         database:set('bot:cmd:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `Şİá ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^İÊÍ (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local UNTSHAKE = {string.match(text, "^(İÊÍ) (.*)$")} 
      if unmutept[2] == "all" or UNTSHAKE[2] == "Çáßá" then
	  if database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:muteall'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ßÜÜá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all warn" or UNTSHAKE[2] == "Çáßá ÈÇáÊÍĞíÑ" then
	  if database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:muteallwarn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ßá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all ban" or UNTSHAKE[2] == "Çáßá ÈÇáØÑÏ" then
	  if database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ßá ÇáæÓÇÆØ `??\n\n• `ÎÇÕíÉ : ÈÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:muteallban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ßá ÇáæÓÇÆØ` ??\n\n• `ÎÇÕíÉ : ÈÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text" or UNTSHAKE[2] == "ÇáÏÑÏÔå" then
	  if database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:text:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text ban" or UNTSHAKE[2] == "ÇáÏÑÏÔå ÈÇáØÑÏ" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:text:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text warn" or UNTSHAKE[2] == "ÇáÏÑÏÔå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÏÑÏÔå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:text:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÏÑÏÔå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline" or UNTSHAKE[2] == "ÇáÇäáÇíä" then
	  if database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:inline:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline ban" or UNTSHAKE[2] == "ÇáÇäáÇíä ÈÇáØÑÏ" then
	  if database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:inline:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline warn" or UNTSHAKE[2] == "ÇáÇäáÇíä ÈÇáÊÍĞíÑ" then
	  if database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäáÇíä `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:inline:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäáÇíä` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo" or UNTSHAKE[2] == "ÇáÕæÑ" then
	  if database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:photo:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo ban" or UNTSHAKE[2] == "ÇáÕæÑ ÈÇáØÑÏ" then
	  if database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:photo:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo warn" or UNTSHAKE[2] == "ÇáÕæÑ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÑ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:photo:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÑ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video" or UNTSHAKE[2] == "ÇáİíÏíæ" then
	  if database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:video:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video ban" or UNTSHAKE[2] == "ÇáİíÏíæ ÈÇáØÑÏ" then
	  if database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÈÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:video:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÈÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video warn" or UNTSHAKE[2] == "ÇáİíÏíæ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáİíÏíæåÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:video:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáİíÏíæåÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif" or UNTSHAKE[2] == "ÇáãÊÍÑßå" then
	  if database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:gifs:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif ban" or UNTSHAKE[2] == "ÇáãÊÍÑßå ÈÇáØÑÏ" then
	  if database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:gifs:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif warn" or UNTSHAKE[2] == "ÇáãÊÍÑßå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÊÍÑßå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:gifs:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÊÍÑßå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music" or UNTSHAKE[2] == "ÇáÇÛÇäí" then
	  if database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:music:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music ban" or UNTSHAKE[2] == "ÇáÇÛÇäí ÈÇáØÑÏ" then
	  if database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:music:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music warn" or UNTSHAKE[2] == "ÇáÇÛÇäí ÈÇáÊÍĞíÑ" then
	  if database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇÛÇäí `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:music:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇÛÇäí` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice" or UNTSHAKE[2] == "ÇáÕæÊ" then
	  if database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:voice:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice ban" or UNTSHAKE[2] == "ÇáÕæÊ ÈÇáØÑÏ" then
	  if database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:voice:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice warn" or UNTSHAKE[2] == "ÇáÕæÊ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÕæÊíÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:voice:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÕæÊíÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links" or UNTSHAKE[2] == "ÇáÑæÇÈØ" then
	  if database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:links:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links ban" or UNTSHAKE[2] == "ÇáÑæÇÈØ ÈÇáØÑÏ" then
	  if database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:links:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links warn" or UNTSHAKE[2] == "ÇáÑæÇÈØ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÑæÇÈØ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:links:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÑæÇÈØ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location" or UNTSHAKE[2] == "ÇáÔÈßÇÊ" then
	  if database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:location:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location ban" or UNTSHAKE[2] == "ÇáÔÈßÇÊ ÈÇáØÑÏ" then
	  if database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:location:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location warn" or UNTSHAKE[2] == "ÇáÔÈßÇÊ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÈßÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:location:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÈßÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end 
      end
      if unmutept[2] == "tag" or UNTSHAKE[2] == "ÇáãÚÑİ" then
	  if database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:tag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag ban" or UNTSHAKE[2] == "ÇáãÚÑİ ÈÇáØÑÏ" then
	  if database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:tag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag warn" or UNTSHAKE[2] == "ÇáãÚÑİ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÚÑİÇÊ <@> `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:tag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÚÑİÇÊ <@>` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag" or UNTSHAKE[2] == "ÇáÊÇß" then
	  if database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:hashtag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag ban" or UNTSHAKE[2] == "ÇáÊÇß ÈÇáØÑÏ" then
	  if database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:hashtag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag warn" or UNTSHAKE[2] == "ÇáÊÇß ÈÇáÊÍĞíÑ" then
	  if database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊÇßÇÊ <#> `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:hashtag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊÇßÇÊ <#>` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact" or UNTSHAKE[2] == "ÇáÌåÇÊ" then
	  if database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:contact:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact ban" or UNTSHAKE[2] == "ÇáÌåÇÊ ÈÇáØÑÏ" then
	  if database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:contact:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact warn" or UNTSHAKE[2] == "ÇáÌåÇÊ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:contact:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÌåÇÊ ÇáÇÊÕÇá` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage" or UNTSHAKE[2] == "ÇáãæÇŞÚ" then
	  if database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:webpage:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage ban" or UNTSHAKE[2] == "ÇáãæÇŞÚ ÈÇáØÑÏ" then
	  if database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:webpage:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage warn" or UNTSHAKE[2] == "ÇáãæÇŞÚ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãæÇŞÚ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:webpage:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãæÇŞÚ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
    end
      if unmutept[2] == "arabic" or UNTSHAKE[2] == "ÇáÚÑÈíå" then
	  if database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:arabic:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic ban" or UNTSHAKE[2] == "ÇáÚÑÈíå ÈÇáØÑÏ" then
	  if database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:arabic:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic warn" or UNTSHAKE[2] == "ÇáÚÑÈíå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÚÑÈíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:arabic:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÚÑÈíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english" or UNTSHAKE[2] == "ÇáÇäßáíÒíå" then
	  if database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:english:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english ban" or UNTSHAKE[2] == "ÇáÇäßáíÒíå ÈÇáØÑÏ" then
	  if database:get('bot:english:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:english:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english warn" or UNTSHAKE[2] == "ÇáÇäßáíÒíå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇäßáíÒíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:english:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇäßáíÒíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam del" or UNTSHAKE[2] == "ÇáßáÇíÔ" then
	  if database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáßáÇíÔ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:spam:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáßáÇíÔ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam warn" or UNTSHAKE[2] == "ÇáßáÇíÔ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáßáÇíÔ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:spam:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáßáÇíÔ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker" or UNTSHAKE[2] == "ÇáãáÕŞÇÊ" then
	  if database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:sticker:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker ban" or UNTSHAKE[2] == "ÇáãáÕŞÇÊ ÈÇáØÑÏ" then
	  if database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:sticker:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker warn" or UNTSHAKE[2] == "ÇáãáÕŞÇÊ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáÕŞÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:sticker:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáÕŞÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
    end

      if unmutept[2] == "file" or UNTSHAKE[2] == "ÇáãáİÇÊ" then
	  if database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:document:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file ban" or UNTSHAKE[2] == "ÇáãáİÇÊ ÈÇáØÑÏ" then
	  if database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:document:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file warn" or UNTSHAKE[2] == "ÇáãáİÇÊ ÈÇáÊÍĞíÑ" then
	  if database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãáİÇÊ `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:document:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãáİÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end    

      if unmutept[2] == "markdown" or UNTSHAKE[2] == "ÇáãÇÑßÏæä" then
	  if database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:markdown:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown ban" or UNTSHAKE[2] == "ÇáãÇÑßÏæä ÈÇáØÑÏ" then
	  if database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:markdown:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown warn" or UNTSHAKE[2] == "ÇáãÇÑßÏæä ÈÇáÊÍĞíÑ" then
	  if database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáãÇÑßÏæä `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:markdown:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáãÇÑßÏæä` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end    


	  if unmutept[2] == "service" or UNTSHAKE[2] == "ÇáÇÔÚÇÑÇÊ" then
	  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÇÔÚÇÑÇÊ `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:tgservice:mute'..msg.chat_id_)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÇÔÚÇÑÇÊ` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd" or UNTSHAKE[2] == "ÇáÊæÌíå" then
	  if database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:forward:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd ban" or UNTSHAKE[2] == "ÇáÊæÌíå ÈÇáØÑÏ" then
	  if database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:forward:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd warn" or UNTSHAKE[2] == "ÇáÊæÌíå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÊæÌíå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:forward:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÊæÌíå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd" or UNTSHAKE[2] == "ÇáÔÇÑÍå" then
	  if database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáãÓÍ `??', 1, 'md')
      end
         database:del('bot:cmd:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáãÓÍ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd ban" or UNTSHAKE[2] == "ÇáÔÇÑÍå ÈÇáØÑÏ" then
	  if database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáØÑÏ `??', 1, 'md')
      end
         database:del('bot:cmd:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáØÑÏ` ??', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd warn" or UNTSHAKE[2] == "ÇáÔÇÑÍå ÈÇáÊÍĞíÑ" then
	  if database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `Êã `?? `İÊÍ ÇáÔÇÑÍå `??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ `??', 1, 'md')
      end
         database:del('bot:cmd:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã` ?? `İÊÍ ÇáÔÇÑÍå` ??\n\n• `ÎÇÕíÉ : ÇáÊÍĞíÑ` ??', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÊÚÏíá','edit')
  	if text:match("^[Ee][Dd][Ii][Tt] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local editmsg = {string.match(text, "^([Ee][Dd][Ii][Tt]) (.*)$")} 
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'html')
    if database:get('lang:gp:'..msg.chat_id_) then
		 	          send(msg.chat_id_, msg.id_, 1, '*Done* _Edit My Msg_', 1, 'md')
else 
		 	          send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚÏíá ÇáÑÓÇáå` ????', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ãÓÍ ŞÇÆãå ÇáÚÇã$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> Banall has been_ *Cleaned*'
    else 
      text = '• `Êã ãÓÍ ŞÇÆãå ÇáÚÇã` ???'
end
      database:del('bot:gbanned:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end

    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Aa][Dd][Mm][Ii][Nn][Ss]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ãÓÍ ÇÏãäíå ÇáÈæÊ$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> adminlist has been_ *Cleaned*'
    else 
      text = '• `Êã ãÓÍ ŞÇÆãå ÇÏãäíå ÇáÈæÊ` ???'
end
      database:del('bot:admins:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ãÓÍ','clean')
  	if text:match("^[Cc][Ll][Ee][Aa][Nn] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Cc][Ll][Ee][Aa][Nn]) (.*)$")} 
       if txt[2] == 'banlist' or txt[2] == 'Banlist' or txt[2] == 'ÇáãÍÙæÑíä' then
	      database:del('bot:banned:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáãÍÙæÑíä` ???', 1, 'md')
end
       end
	   if txt[2] == 'bots' or txt[2] == 'Bots' or txt[2] == 'ÇáÈæÊÇÊ' then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].msg.sender_user_id_)
          end 
      end
    channel_get_bots(msg.chat_id_,g_bots) 
    if database:get('lang:gp:'..msg.chat_id_) then
	          send(msg.chat_id_, msg.id_, 1, '_> All bots_ *kicked!*', 1, 'md')
          else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ØÑÏ ÌãíÚ ÇáÈæÊÇÊ` ???', 1, 'md')
end
	end
	   if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'ÇáÇÏãäíå' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:mods:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Modlist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáÇÏãäíå` ???', 1, 'md')
end
     end 
	   if txt[2] == 'viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'ÇáÇÚÖÇÁ ÇáããíÒíä' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:vipgp:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Viplist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáÇÚÖÇÁ ÇáããíÒíä` ???', 1, 'md')
end
       end 
	   if txt[2] == 'owners' and is_sudo(msg) or txt[2] == 'Owners' and is_sudo(msg) or txt[2] == 'ÇáãÏÑÇÁ' and is_sudo(msg) then
	      database:del('bot:owners:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> ownerlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáãÏÑÇÁ` ???', 1, 'md')
end
       end
	   if txt[2] == 'rules' or txt[2] == 'Rules' or txt[2] == 'ÇáŞæÇäíä' then
	      database:del('bot:rules'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> rules has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ÇáŞæÇäíä ÇáãÍİæÙå` ???', 1, 'md')
end
       end
	   if txt[2] == 'link' or  txt[2] == 'Link' or  txt[2] == 'ÇáÑÇÈØ' then
	      database:del('bot:group:link'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> link has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ÇáÑÇÈØ ÇáãÍİæÙ` ???', 1, 'md')
end
       end
	   if txt[2] == 'badlist' or txt[2] == 'Badlist' or txt[2] == 'ŞÇÆãå ÇáãäÚ' then
	      database:del('bot:filters:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> badlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáãäÚ` ???', 1, 'md')
end
       end
	   if txt[2] == 'silentlist' or txt[2] == 'Silentlist' or txt[2] == 'ÇáãßÊæãíä' then
	      database:del('bot:muted:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> silentlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '• `Êã ãÓÍ ŞÇÆãå ÇáãßÊæãíä` ???', 1, 'md')
end
       end
       
    end 
	-----------------------------------------------------------------------------------------------
  	 if text:match("^[Ss] [Dd][Ee][Ll]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`lock | ??`'
	else
	mute_all = '`unlock | ??`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`lock | ??`'
	else
	mute_text = '`unlock | ??`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`lock | ??`'
	else
	mute_photo = '`unlock | ??`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`lock | ??`'
	else
	mute_video = '`unlock | ??`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`lock | ??`'
	else
	mute_gifs = '`unlock | ??`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`unlock | ??`'
	else  
	mute_flood = '`lock | ??`'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`lock | ??`'
	else
	mute_music = '`unlock | ??`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`lock | ??`'
	else
	mute_bots = '`unlock | ??`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`lock | ??`'
	else
	mute_in = '`unlock | ??`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`lock | ??`'
	else
	mute_voice = '`unlock | ??`'
end

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`lock | ??`'
	else
	mute_doc = '`unlock | ??`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`lock | ??`'
	else
	mute_mdd = '`unlock | ??`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`lock | ??`'
	else
	mute_edit = '`unlock | ??`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`lock | ??`'
	else
	mute_links = '`unlock | ??`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`lock | ??`'
	else
	lock_pin = '`unlock | ??`'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`lock | ??`'
	else
	lock_sticker = '`unlock | ??`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`lock | ??`'
	else
	lock_tgservice = '`unlock | ??`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`lock | ??`'
	else
	lock_wp = '`unlock | ??`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`lock | ??`'
	else
	lock_htag = '`unlock | ??`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`lock | ??`'
	else
	lock_cmd = '`unlock | ??`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`lock | ??`'
	else
	lock_tag = '`unlock | ??`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`lock | ??`'
	else
	lock_location = '`unlock | ??`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end

	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`lock | ??`'
	else
	lock_contact = '`unlock | ??`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`lock | ??`'
	else
	mute_spam = '`unlock | ??`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`unlock | ??`'
	else 
	lock_flood = '`lock | ??`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`unlock | ??`'
	else 
	del_flood = '`lock | ??`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`lock | ??`'
	else
	lock_english = '`unlock | ??`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`lock | ??`'
	else
	lock_arabic = '`unlock | ??`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`lock | ??`'
	else
	lock_forward = '`unlock | ??`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`lock | ??`'
	else
	lock_rep = '`unlock | ??`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`active | ?`'
	else
	send_welcome = '`inactive | ?`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
		if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Del*\n======================\n*Del all* : "..mute_all.."\n" .."*Del Links* : "..mute_links.."\n" .."*Del Edit* : "..mute_edit.."\n" .."*Del Bots* : "..mute_bots.."\n" .."*Del Inline* : "..mute_in.."\n" .."*Del English* : "..lock_english.."\n" .."*Del Forward* : "..lock_forward.."\n" .."*Del Pin* : "..lock_pin.."\n" .."*Del Arabic* : "..lock_arabic.."\n" .."*Del Hashtag* : "..lock_htag.."\n".."*Del tag* : "..lock_tag.."\n" .."*Del Webpage* : "..lock_wp.."\n" .."*Del Location* : "..lock_location.."\n" .."*Del Tgservice* : "..lock_tgservice.."\n"
.."*Del Spam* : "..mute_spam.."\n" .."*Del Photo* : "..mute_photo.."\n" .."*Del Text* : "..mute_text.."\n" .."*Del Gifs* : "..mute_gifs.."\n" .."*Del Voice* : "..mute_voice.."\n" .."*Del Music* : "..mute_music.."\n" .."*Del Video* : "..mute_video.."\n*Del Cmd* : "..lock_cmd.."\n" .."*Del Markdown* : "..mute_mdd.."\n*Del Document* : "..mute_doc.."\n" .."*Flood Ban* : "..mute_flood.."\n" .."*Flood Mute* : "..lock_flood.."\n" .."*Flood del* : "..del_flood.."\n" .."*Setting reply* : "..lock_rep.."\n"
.."======================\n*Welcome* : "..send_welcome.."\n*Flood Time*  "..flood_t.."\n" .."*Flood Max* : "..flood_m.."\n" .."*Flood Mute* : "..flood_warn.."\n" .."*Flood del* : "..flood_del.."\n" .."*Number Spam* : "..spam_c.."\n" .."*Warn Spam* : "..spam_d.."\n"
 .."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end

          local text = msg.content_.text_:gsub('ÇÚÏÇÏÇÊ ÇáãÓÍ','sdd1')
  	 if text:match("^[Ss][Dd][Dd]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`ãİÚá | ??`'
	else
	mute_all = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`ãİÚá | ??`'
	else
	mute_text = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`ãİÚá | ??`'
	else
	mute_photo = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`ãİÚá | ??`'
	else
	mute_video = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`ãİÚá | ??`'
	else
	mute_gifs = '`ãÚØá | ??`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`ãÚØá | ??`'
	else  
	mute_flood = '`ãİÚá | ??`'
end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`ãİÚá | ??`'
	else
	mute_music = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`ãİÚá | ??`'
	else
	mute_bots = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`ãİÚá | ??`'
	else
	mute_in = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`ãİÚá | ??`'
	else
	mute_voice = '`ãÚØá | ??`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`ãİÚá | ??`'
	else
	mute_edit = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`ãİÚá | ??`'
	else
	mute_links = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`ãİÚá | ??`'
	else
	lock_pin = '`ãÚØá | ??`'
end 

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`ãİÚá | ??`'
	else
	mute_doc = '`ãÚØá | ??`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`ãİÚá | ??`'
	else
	mute_mdd = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`ãİÚá | ??`'
	else
	lock_sticker = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`ãİÚá | ??`'
	else
	lock_tgservice = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`ãİÚá | ??`'
	else
	lock_wp = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`ãİÚá | ??`'
	else
	lock_htag = '`ãÚØá | ??`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`ãİÚá | ??`'
	else
	lock_cmd = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`ãİÚá | ??`'
	else
	lock_tag = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`ãİÚá | ??`'
	else
	lock_location = '`ãÚØá | ??`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end
	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`ãİÚá | ??`'
	else
	lock_contact = '`ãÚØá | ??`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`ãİÚá | ??`'
	else
	mute_spam = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`ãİÚá | ??`'
	else
	lock_english = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`ãİÚá | ??`'
	else
	lock_arabic = '`ãÚØá | ??`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`ãÚØá | ??`'
	else 
	lock_flood = '`ãİÚá | ??`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`ãÚØá | ??`'
	else 
	del_flood = '`ãİÚá | ??`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`ãİÚá | ??`'
	else
	lock_forward = '`ãÚØá | ??`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`ãÚØáå | ??`'
	else
	lock_rep = '`ãİÚáå | ??`'
	end

    if database:get('bot:repsudo:mute'..msg.chat_id_) then
	lock_repsudo = '`ãÚØáå | ??`'
	else
	lock_repsudo = '`ãİÚáå | ??`'
	end
	
    if database:get('bot:repowner:mute'..msg.chat_id_) then
	lock_repowner = '`ãÚØáå | ??`'
	else
	lock_repowner = '`ãİÚáå | ??`'
	end

    if database:get('bot:id:mute'..msg.chat_id_) then
	lock_id = '`ãÚØá | ??`'
	else
	lock_id = '`ãİÚá | ??`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`ãİÚá | ?`'
	else
	send_welcome = '`ãÚØá | ?`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
	if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`áÇ äåÇÆí`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "• `ÇÚÏÇÏÇÊ ÇáãÌãæÚå ÈÇáãÓÍ`\n? • • • • • • • • • • • • • ?\n• `ßá ÇáæÓÇÆØ` : "..mute_all.."\n"
	 .."• `ÇáÑæÇÈØ` : "..mute_links.."\n"
	 .."• `ÇáÊÚÏíá` : "..mute_edit.."\n" 
	 .."• `ÇáÈæÊÇÊ` : "..mute_bots.."\n"
	 .."• `ÇááÛå ÇáÇäßáíÒíå` : "..lock_english.."\n"
	 .."• `ÇÚÇÏå ÇáÊæÌíå` : "..lock_forward.."\n" 
	 .."• `ÇáãæÇŞÚ` : "..lock_wp.."\n" 
	 .."• `ÇáÊËÈíÊ` : "..lock_pin.."\n" 
	 .."• `ÇááÛå ÇáÚÑÈíå` : "..lock_arabic.."\n\n"
	 .."• `ÇáÊÇßÇÊ` : "..lock_htag.."\n"
	 .."• `ÇáãÚÑİÇÊ` : "..lock_tag.."\n" 
	 .."• `ÇáÔÈßÇÊ` : "..lock_location.."\n" 
	 .."• `ÇáÇÔÚÇÑÇÊ` : "..lock_tgservice.."\n"
   .."• `ÇáßáÇíÔ` : "..mute_spam.."\n"
   .."• `ÇáÊßÑÇÑ ÈÇáØÑÏ` : "..mute_flood.."\n" 
   .."• `ÇáÊßÑÇÑ ÈÇáßÊã` : "..lock_flood.."\n" 
   .."• `ÇáÊßÑÇÑ ÈÇáãÓÍ` : "..del_flood.."\n" 
   .."• `ÇáÏÑÏÔå` : "..mute_text.."\n"
   .."• `ÇáÕæÑ ÇáãÊÍÑßå` : "..mute_gifs.."\n\n"
   .."• `ÇáÕæÊíÇÊ` : "..mute_voice.."\n" 
   .."• `ÇáÇÛÇäí` : "..mute_music.."\n"
	 .."• `ÇáÇäáÇíä` : "..mute_in.."\n" 
   .."• `ÇáãáÕŞÇÊ` : "..lock_sticker.."\n"
	 .."• `ÌåÇÊ ÇáÇÊÕÇá` : "..lock_contact.."\n" 
   .."• `ÇáİíÏíæåÇÊ` : "..mute_video.."\n• `ÇáÔÇÑÍå` : "..lock_cmd.."\n"
   .."• `ÇáãÇÑßÏæä` : "..mute_mdd.."\n• `ÇáãáİÇÊ` : "..mute_doc.."\n" 
   .."• `ÇáÕæÑ` : "..mute_photo.."\n"
   .."• `ÑÏæÏ ÇáÈæÊ` : "..lock_rep.."\n"
   .."• `ÑÏæÏ ÇáãØæÑ` : "..lock_repsudo.."\n"
   .."• `ÑÏæÏ ÇáãÏíÑ` : "..lock_repowner.."\n"
   .."• `ÇáÇíÏí` : "..lock_id.."\n\n"
   .."? • • • • • • • • • • • • • ?\n• `ÇáÊÑÍíÈ` : "..send_welcome.."\n• `Òãä ÇáÊßÑÇÑ` : "..flood_t.."\n"
   .."• `ÚÏÏ ÇáÊßÑÇÑ ÈÇáØÑÏ` : "..flood_m.."\n"
   .."• `ÚÏÏ ÇáÊßÑÇÑ ÈÇáßÊã` : "..flood_warn.."\n\n"
   .."• `ÚÏÏ ÇáÊßÑÇÑ ÈÇáãÓÍ` : "..flood_del.."\n"
   .."• `ÚÏÏ ÇáßáÇíÔ ÈÇáãÓÍ` : "..spam_c.."\n"
   .."• `ÚÏÏ ÇáßáÇíÔ ÈÇáÊÍĞíÑ` : "..spam_d.."\n"
   .."• `ÇäŞÖÇÁ ÇáÈæÊ` : "..exp_dat.." `íæã`\n? • • • • • • • • • • • • • ?"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Ww][Aa][Rr][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`lock | ??`'
	else
	mute_all = '`unlock | ??`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`lock | ??`'
	else
	mute_text = '`unlock | ??`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`lock | ??`'
	else
	mute_photo = '`unlock | ??`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`lock | ??`'
	else
	mute_video = '`unlock | ??`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`lock | ??`'
	else
	mute_spam = '`unlock | ??`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`lock | ??`'
	else
	mute_gifs = '`unlock | ??`'
end

	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`lock | ??`'
	else
	mute_music = '`unlock | ??`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`lock | ??`'
	else
	mute_in = '`unlock | ??`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`lock | ??`'
	else
	mute_voice = '`unlock | ??`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`lock | ??`'
	else
	mute_links = '`unlock | ??`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`lock | ??`'
	else
	lock_sticker = '`unlock | ??`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`lock | ??`'
	else
	lock_cmd = '`unlock | ??`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`lock | ??`'
	else
	lock_wp = '`unlock | ??`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`lock | ??`'
	else
	mute_doc = '`unlock | ??`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`lock | ??`'
	else
	mute_mdd = '`unlock | ??`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`lock | ??`'
	else
	lock_htag = '`unlock | ??`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`lock | ??`'
	else
	lock_pin = '`unlock | ??`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`lock | ??`'
	else
	lock_tag = '`unlock | ??`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`lock | ??`'
	else
	lock_location = '`unlock | ??`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`lock | ??`'
	else
	lock_contact = '`unlock | ??`'
	end
	------------
	
    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`lock | ??`'
	else
	lock_english = '`unlock | ??`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`lock | ??`'
	else
	lock_arabic = '`unlock | ??`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`lock | ??`'
	else
	lock_forward = '`unlock | ??`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Warn*\n======================\n*Warn all* : "..mute_all.."\n" .."*Warn Links* : "..mute_links.."\n" .."*Warn Inline* : "..mute_in.."\n" .."*Warn Pin* : "..lock_pin.."\n" .."*Warn English* : "..lock_english.."\n" .."*Warn Forward* : "..lock_forward.."\n" .."*Warn Arabic* : "..lock_arabic.."\n" .."*Warn Hashtag* : "..lock_htag.."\n".."*Warn tag* : "..lock_tag.."\n" .."*Warn Webpag* : "..lock_wp.."\n" .."*Warn Location* : "..lock_location.."\n"
.."*Warn Spam* : "..mute_spam.."\n" .."*Warn Photo* : "..mute_photo.."\n" .."*Warn Text* : "..mute_text.."\n" .."*Warn Gifs* : "..mute_gifs.."\n" .."*Warn Voice* : "..mute_voice.."\n" .."*Warn Music* : "..mute_music.."\n" .."*Warn Video* : "..mute_video.."\n*Warn Cmd* : "..lock_cmd.."\n"  .."*Warn Markdown* : "..mute_mdd.."\n*Warn Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end


          local text = msg.content_.text_:gsub('ÇÚÏÇÏÇÊ ÇáÊÍĞíÑ','sdd2')
  	 if text:match("^[Ss][Dd][Dd]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`ãİÚá | ??`'
	else
	mute_all = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`ãİÚá | ??`'
	else
	mute_text = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`ãİÚá | ??`'
	else
	mute_photo = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`ãİÚá | ??`'
	else
	mute_video = '`ãÚØá | ??`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`ãİÚá | ??`'
	else
	mute_spam = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`ãİÚá | ??`'
	else
	mute_gifs = '`ãÚØá | ??`'
end
	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`ãİÚá | ??`'
	else
	mute_music = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`ãİÚá | ??`'
	else
	mute_in = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`ãİÚá | ??`'
	else
	mute_voice = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`ãİÚá | ??`'
	else
	mute_links = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`ãİÚá | ??`'
	else
	lock_sticker = '`ãÚØá | ??`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`ãİÚá | ??`'
	else
	lock_cmd = '`ãÚØá | ??`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`ãİÚá | ??`'
	else
	lock_wp = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`ãİÚá | ??`'
	else
	lock_htag = '`ãÚØá | ??`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`ãİÚá | ??`'
	else
	lock_pin = '`ãÚØá | ??`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`ãİÚá | ??`'
	else
	lock_tag = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`ãİÚá | ??`'
	else
	lock_location = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`ãİÚá | ??`'
	else
	lock_contact = '`ãÚØá | ??`'
	end

    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`ãİÚá | ??`'
	else
	lock_english = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`ãİÚá | ??`'
	else
	lock_arabic = '`ãÚØá | ??`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`ãİÚá | ??`'
	else
	mute_doc = '`ãÚØá | ??`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`ãİÚá | ??`'
	else
	mute_mdd = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`ãİÚá | ??`'
	else
	lock_forward = '`ãÚØá | ??`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`áÇ äåÇÆí`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "• `ÇÚÏÇÏÇÊ ÇáãÌãæÚå ÈÇáÊÍĞíÑ`\n? • • • • • • • • • • • • • ?\n• `ßá ÇáæÓÇÆØ` : "..mute_all.."\n"
	 .."• `ÇáÑæÇÈØ` : "..mute_links.."\n"
	 .."• `ÇáÇäáÇíä` : "..mute_in.."\n"
	 .."• `ÇáÊËÈíÊ` : "..lock_pin.."\n"
	 .."• `ÇááÛå ÇáÇäßáíÒíå` : "..lock_english.."\n"
	 .."• `ÇÚÇÏå ÇáÊæÌíå` : "..lock_forward.."\n"
	 .."• `ÇááÛå ÇáÚÑÈíå` : "..lock_arabic.."\n"
	 .."• `ÇáÊÇßÇÊ` : "..lock_htag.."\n"
	 .."• `ÇáãÚÑİÇÊ` : "..lock_tag.."\n" 
	 .."• `ÇáãæÇŞÚ` : "..lock_wp.."\n"
	 .."• `ÇáÔÈßÇÊ` : "..lock_location.."\n" 
   .."• `ÇáßáÇíÔ` : "..mute_spam.."\n\n" 
   .."• `ÇáÕæÑ` : "..mute_photo.."\n" 
   .."• `ÇáÏÑÏÔå` : "..mute_text.."\n"
   .."• `ÇáÕæÑ ÇáãÊÍÑßå` : "..mute_gifs.."\n"
   .."• `ÇáãáÕŞÇÊ` : "..lock_sticker.."\n"
	 .."• `ÌåÇÊ ÇáÇÊÕÇá` : "..lock_contact.."\n" 
   .."• `ÇáÕæÊíÇÊ` : "..mute_voice.."\n" 
   .."• `ÇáÇÛÇäí` : "..mute_music.."\n" 
   .."• `ÇáİíÏíæåÇÊ` : "..mute_video.."\n• `ÇáÔÇÑÍå` : "..lock_cmd.."\n"
   .."• `ÇáãÇÑßÏæä` : "..mute_mdd.."\n• `ÇáãáİÇÊ` : "..mute_doc.."\n" 
   .."\n• `ÇäŞÖÇÁ ÇáÈæÊ` : "..exp_dat.." `íæã`\n" .."? • • • • • • • • • • • • • ?"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`lock | ??`'
	else
	mute_all = '`unlock | ??`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`lock | ??`'
	else
	mute_text = '`unlock | ??`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`lock | ??`'
	else
	mute_photo = '`unlock | ??`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`lock | ??`'
	else
	mute_video = '`unlock | ??`'
end

	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`lock | ??`'
	else
	mute_gifs = '`unlock | ??`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`lock | ??`'
	else
	mute_music = '`unlock | ??`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`lock | ??`'
	else
	mute_in = '`unlock | ??`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`lock | ??`'
	else
	mute_voice = '`unlock | ??`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`lock | ??`'
	else
	mute_links = '`unlock | ??`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`lock | ??`'
	else
	lock_sticker = '`unlock | ??`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`lock | ??`'
	else
	lock_cmd = '`unlock | ??`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`lock | ??`'
	else
	lock_wp = '`unlock | ??`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`lock | ??`'
	else
	lock_htag = '`unlock | ??`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`lock | ??`'
	else
	lock_tag = '`unlock | ??`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`lock | ??`'
	else
	lock_location = '`unlock | ??`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`lock | ??`'
	else
	lock_contact = '`unlock | ??`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`lock | ??`'
	else
	lock_english = '`unlock | ??`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`lock | ??`'
	else
	lock_arabic = '`unlock | ??`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`lock | ??`'
	else
	lock_forward = '`unlock | ??`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`lock | ??`'
	else
	mute_doc = '`unlock | ??`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`lock | ??`'
	else
	mute_mdd = '`unlock | ??`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Ban*\n======================\n*Ban all* : "..mute_all.."\n" .."*Ban Links* : "..mute_links.."\n" .."*Ban Inline* : "..mute_in.."\n" .."*Ban English* : "..lock_english.."\n" .."*Ban Forward* : "..lock_forward.."\n" .."*Ban Arabic* : "..lock_arabic.."\n" .."*Ban Hashtag* : "..lock_htag.."\n".."*Ban tag* : "..lock_tag.."\n" .."*Ban Webpage* : "..lock_wp.."\n" .."*Ban Location* : "..lock_location.."\n"
.."*Ban Photo* : "..mute_photo.."\n" .."*Ban Text* : "..mute_text.."\n" .."*Ban Gifs* : "..mute_gifs.."\n" .."*Ban Voice* : "..mute_voice.."\n" .."*Ban Music* : "..mute_music.."\n" .."*Ban Video* : "..mute_video.."\n*Ban Cmd* : "..lock_cmd.."\n"  .."*Ban Markdown* : "..mute_mdd.."\n*Ban Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
          local text = msg.content_.text_:gsub('ÇÚÏÇÏÇÊ ÇáØÑÏ','sdd3')
  	 if text:match("^[Ss][Dd][Dd]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`ãİÚá | ??`'
	else
	mute_all = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`ãİÚá | ??`'
	else
	mute_text = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`ãİÚá | ??`'
	else
	mute_photo = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`ãİÚá | ??`'
	else
	mute_video = '`ãÚØá | ??`'
end
	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`ãİÚá | ??`'
	else
	mute_gifs = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`ãİÚá | ??`'
	else
	mute_music = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`ãİÚá | ??`'
	else
	mute_in = '`ãÚØá | ??`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`ãİÚá | ??`'
	else
	mute_voice = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`ãİÚá | ??`'
	else
	mute_links = '`ãÚØá | ??`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`ãİÚá | ??`'
	else
	lock_sticker = '`ãÚØá | ??`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`ãİÚá | ??`'
	else
	lock_cmd = '`ãÚØá | ??`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`ãİÚá | ??`'
	else
	lock_wp = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`ãİÚá | ??`'
	else
	lock_htag = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`ãİÚá | ??`'
	else
	lock_tag = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`ãİÚá | ??`'
	else
	lock_location = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`ãİÚá | ??`'
	else
	lock_contact = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`ãİÚá | ??`'
	else
	lock_english = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`ãİÚá | ??`'
	else
	lock_arabic = '`ãÚØá | ??`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`ãİÚá | ??`'
	else
	lock_forward = '`ãÚØá | ??`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`ãİÚá | ??`'
	else
	mute_doc = '`ãÚØá | ??`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`ãİÚá | ??`'
	else
	mute_mdd = '`ãÚØá | ??`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`áÇ äåÇÆí`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "• `ÇÚÏÇÏÇÊ ÇáãÌãæÚå ÈÇáØÑÏ`\n? • • • • • • • • • • • • • ?\n• `ßá ÇáæÓÇÆØ` : "..mute_all.."\n"
	 .."• `ÇáÑæÇÈØ` : "..mute_links.."\n" 
	 .."• `ÇáÇäáÇíä` : "..mute_in.."\n"
	 .."• `ÇááÛå ÇáÇäßáíÒíå` : "..lock_english.."\n"
	 .."• `ÇÚÇÏå ÇáÊæÌíå` : "..lock_forward.."\n" 
	 .."• `ÇááÛå ÇáÚÑÈíå` : "..lock_arabic.."\n"
	 .."• `ÇáÊÇßÇÊ` : "..lock_htag.."\n"
	 .."• `ÇáãÚÑİÇÊ` : "..lock_tag.."\n" 
	 .."• `ÇáãæÇŞÚ` : "..lock_wp.."\n" 
	 .."• `ÇáÔÈßÇÊ` : "..lock_location.."\n\n"
   .."• `ÇáÕæÑ` : "..mute_photo.."\n" 
   .."• `ÇáÏÑÏÔå` : "..mute_text.."\n" 
   .."• `ÇáÕæÑ ÇáãÊÍÑßå` : "..mute_gifs.."\n" 
   .."• `ÇáãáÕŞÇÊ` : "..lock_sticker.."\n"
	 .."• `ÌåÇÊ ÇáÇÊÕÇá` : "..lock_contact.."\n" 
   .."• `ÇáÕæÊíÇÊ` : "..mute_voice.."\n"
   .."• `ÇáÇÛÇäí` : "..mute_music.."\n"  
   .."• `ÇáİíÏíæåÇÊ` : "..mute_video.."\n• `ÇáÔÇÑÍå` : "..lock_cmd.."\n"
   .."• `ÇáãÇÑßÏæä` : "..mute_mdd.."\n• `ÇáãáİÇÊ` : "..mute_doc.."\n" 
   .."• `ÇäŞÖÇÁ ÇáÈæÊ` : "..exp_dat.." `íæã`\n" .."? • • • • • • • • • • • • • ?"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
     
  ----------------------------------------------------------------------------------------------- 
if text:match("^[Dd][Ee][Vv]$")or text:match("^ãØæÑ ÈæÊ$") or text:match("^ãØæÑíä$") or text:match("^ãØæÑ ÇáÈæÊ$") or text:match("^ãØæÑ$") or text:match("^ÇáãØæÑ$") and msg.reply_to_message_id_ == 0 then
local nkeko = redis:get('nmkeko'..bot_id)
local nakeko = redis:get('nakeko'..bot_id)
  
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, (nkeko or 9647707641864), (nakeko or "TshAke TEAM"), "", bot_id)
end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('ÊÛíÑ ÇãÑ ÇáãØæÑ','change ph')
if text:match("^[Cc][Hh][Aa][Nn][Gg][Ee] [Pp][Hh]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *developer number*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÇä íãßäß ÇÑÓÇá ÑŞã ÇáãØæÑ` ??', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^+(.*)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *name of the developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÇä íãßäß ÇÑÓÇá ÇáÇÓã ÇáĞí ÊÑíÏå` ??', 1, 'md')
end
redis:set('nmkeko'..bot_id, text)  
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'mmsg')  
  return false end  
end
if text:match("^(.*)$") then
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'mmsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved Send a_ *DEV to watch the changes*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `Êã ÍİÙ ÇáÇÓã íãßäß ÇÙåÇÑ ÇáÌå ÈÜ ÇÑÓÇá ÇãÑ ÇáãØæÑ` ??', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:set('nakeko'..bot_id, text)  
local nmkeko = redis:get('nmkeko'..bot_id)
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, nmkeko, text , "", bot_id)
  return false end  
end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('ÇÖİ ãØæÑ','add sudo')
if text:match("^[Aa][Dd][Dd] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÇä íãßäß ÇÑÓÇá ÇíÏí ÇáãØæÑ ÇáĞí ÊÑíÏ ÑİÚå`??', 1, 'md')
end
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^(%d+)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('qkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been added_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `Êã ÇÖÇİÊå`  '..text..' `ãØæÑ ááÈæÊ`??', 1, 'md')
end
redis:set('sudoo'..text..''..bot_id, 'yes')  
redis:sadd('dev'..bot_id, text)
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'no')  
  return false end  
end  

  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('ÍĞİ ãØæÑ','rem sudo')
if text:match("^[Rr][Ee][Mm] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `ÇáÇä íãßäß ÇÑÓÇá ÇíÏí ÇáãØæÑ ÇáĞí ÊÑíÏ ÍĞİå`??', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
end
if text:match("^(%d+)$") then
local keko2 = redis:get('xkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been removed_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• `Êã ÍĞİå`  '..text..' `ãä ãØæÑíä ÇáÈæÊ`??', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:del('sudoo'..text..''..bot_id, 'no')  
 end  
end

local text = msg.content_.text_:gsub('ÇÖİ ÑÏ','add rep')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇÑÓá Çáßáãå ÇáÊí ÊÑíÏ ÇÖÇİÊåÇ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repowner:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id..''..msg.chat_id_..'')
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇáÇä ÇÑÓá ÇáÑÏ ÇáĞí ÊÑíÏ ÇÖÇİÊå ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('repowner'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
redis:set('keko'..keko2..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('kekore'..bot_id..''..msg.chat_id_..'', keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "• `Êã ÍİÙ ÇáÑÏ` ??", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
end
end  

local text = msg.content_.text_:gsub('ÍĞİ ÑÏ','rem rep')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇÑÓá Çáßáãå ÇáÊí ÊÑíÏ ÍĞİåÇ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• Êã ÍĞİ ÇáÑÏ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
redis:set('keko'..text..''..bot_id..''..msg.chat_id_..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('ÇÖİ ÑÏ ááßá','add rep all')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇÑÓá Çáßáãå ÇáÊí ÊÑíÏ ÇÖÇİÊåÇ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repsudo:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id)
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇáÇä ÇÑÓá ÇáÑÏ ÇáĞí ÊÑíÏ ÇÖÇİÊå ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id, text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id)
redis:set('keko'..keko2..''..bot_id, text)  
redis:sadd('kekoresudo'..bot_id, keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "• `Êã ÍİÙ ÇáÑÏ` ??", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
end
end  
 
local text = msg.content_.text_:gsub('ÍĞİ ÑÏ ááßá','rem rep all')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• ÇÑÓá Çáßáãå ÇáÊí ÊÑíÏ ÍĞİåÇ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '• Êã ÍĞİ ÇáÑÏ ??', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
 redis:set('keko'..text..''..bot_id..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('ãÓÍ ÇáãØæÑíä','clean sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
  local list = redis:smembers('dev'..bot_id)
  for k,v in pairs(list) do
redis:del('dev'..bot_id, text)
redis:del('sudoo'..v..''..bot_id, 'no')  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Bot developers_ *have been cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "• `Êã ãÓÍ ãØæÑíä ÇáÈæÊ` ??", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('ãÓÍ ÑÏæÏ ÇáãÏíÑ','clean rep owner')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  for k,v in pairs(list) do
redis:del('kekore'..bot_id..''..msg.chat_id_..'', text)
redis:set('keko'..v..''..bot_id..''..msg.chat_id_..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Owner replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "• `Êã ãÓÍ ÑÏæÏ ÇáãÏíÑ` ??", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('ãÓÍ ÑÏæÏ ÇáãØæÑ','clean rep sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Ss][Uu][Dd][Oo]$") and is_sudo(msg) then
  local list = redis:smembers('kekoresudo'..bot_id)
  for k,v in pairs(list) do
redis:del('kekoresudo'..bot_id, text)
redis:set('keko'..v..''..bot_id..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Sudo replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "• `Êã ãÓÍ ÑÏæÏ ÇáãØæÑ` ??", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('ÇáãØæÑíä','sudo list')
if text:match("^[Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local list = redis:smembers('dev'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Sudo List :</b>\n? • • • • • • • • • • • • • ?\n• ? :- added\n• ? :- Deleted\n? • • • • • • • • • • • • • ?\n"
else 
  text = "• <code>ŞÇÆãå ÇáãØæÑíä </code>?? :\n? • • • • • • • • • • • • • ?\n• ? :- Êã ÑİÚå\n• ? :- Êã ÊäÒíáå\n? • • • • • • • • • • • • • ?\n"
  end
	for k,v in pairs(list) do
			local keko11 = redis:get('sudoo'..v..''..bot_id)
			local botlua = "?"
       if keko11 == 'yes' then
       botlua = "?"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Sudo List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ãØæÑíä</code> ??"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('ÑÏæÏ ÇáãØæÑ','rep sudo list')
if text:match("^[Rr][Ee][Pp] [Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and is_sudo(msg) then
	local list = redis:smembers('kekoresudo'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep sudo List :</b>\n? • • • • • • • • • • • • • ?\n• ? :- Enabled\n• ? :- Disabled\n? • • • • • • • • • • • • • ?\n"
else 
  text = "• <code>ŞÇÆãå ÑÏæÏ ÇáãØæÑ </code>?? :\n? • • • • • • • • • • • • • ?\n• ? :- ãİÚáå\n• ? :- ãÚØáå\n? • • • • • • • • • • • • • ?\n"
  end
	for k,v in pairs(list) do
  local keko11 = redis:get('keko'..v..''..bot_id)
			local botlua = "?"
       if keko11 == ' ' then
       botlua = "?"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep sudo List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ÑÏæÏ ááãØæÑ</code> ??"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('ÑÏæÏ ÇáãÏíÑ','rep owner list')
if text:match("^[Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr] [Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep owner List :</b>\n? • • • • • • • • • • • • • ?\n• ? :- Enabled\n• ? :- Disabled\n? • • • • • • • • • • • • • ?\n"
else 
  text = "• <code>ŞÇÆãå ÑÏæÏ ÇáãÏíÑ </code>?? :\n? • • • • • • • • • • • • • ?\n• ? :- ãİÚáå\n• ? :- ãÚØáå\n? • • • • • • • • • • • • • ?\n"
  end
	for k,v in pairs(list) do
    local keko11 = redis:get('keko'..v..''..bot_id..''..msg.chat_id_..'')
			local botlua = "?"
       if keko11 == ' ' then
       botlua = "?"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep owner List is empty !</b>"
              else 
                text = "• <code>áÇ íæÌÏ ÑÏæÏ ááãÏíÑ</code> ??"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ßÑÑ','echo')
  	if text:match("^echo (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(echo) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('æÖÚ ŞæÇäíä','setrules')
  	if text:match("^[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, "*> Group rules upadted..._", 1, 'md')
   else 
         send(msg.chat_id_, msg.id_, 1, "• `Êã æÖÚ ÇáŞæÇäíä ááãÌãæÚå` ????", 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Rr][Uu][Ll][Ee][Ss]$")or text:match("^ÇáŞæÇäíä$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
	if rules then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Group Rules :*\n'..rules, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `ŞæÇäíä ÇáãÌãæÚå åí  :` ??\n'..rules, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*rules msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `áã íÊã ÍİÙ ŞæÇäíä ááãÌãæÚå` ???', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
     local text = msg.content_.text_:gsub('æÖÚ ÇÓã','setname')
		if text:match("^[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Nn][Aa][Mm][Ee]) (.*)$")}
	     changetitle(msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group name updated!_\n'..txt[2], 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÍÏíË ÇÓã ÇáãÌãæÚå Çáì ????`\n'..txt[2], 1, 'md')
         end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo]$") or text:match("^æÖÚ ÕæÑå") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Please send a photo noew!_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '• `Şã ÈÇÑÓÇá ÕæÑå ÇáÇä` ????', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('æÖÚ æŞÊ','setexpire')
	if text:match("^[Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^([Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee]) (%d+)$")} 
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group Charged for_ *'..a[2]..'* _Days_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ æŞÊ ÇäÊåÇÁ ÇáÈæÊ` *'..a[2]..'* `íæã` ???', 1, 'md')
end
  end
  
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Tt][Aa][Tt][Ss]$") or text:match("^ÇáæŞÊ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
                if database:get('lang:gp:'..msg.chat_id_) then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
else 
		send(msg.chat_id_, msg.id_, 1, '• `æŞÊ ÇáãÌãæÚå áÇ äåÇÆí` ??', 1, 'md')
end
       else
        local d = math.floor(ex / day ) + 1
                if database:get('lang:gp:'..msg.chat_id_) then
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group Days*", 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, "• `ÚÏÏ ÇíÇã æŞÊ ÇáãÌãæÚå` ??\n"..d.." `íæã` ??", 1, 'md')
end
       end
    end
	-----------------------------------------------------------------------------------------------
    
	if text:match("^æŞÊ ÇáãÌãæÚå (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(æŞÊ ÇáãÌãæÚå) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '• `æŞÊ ÇáãÌãæÚå áÇ äåÇÆí` ??', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
send(msg.chat_id_, msg.id_, 1, "• `ÚÏÏ ÇíÇã æŞÊ ÇáãÌãæÚå` ??\n"..d.." `íæã` ??", 1, 'md')
       end
    end
    
	if text:match("^[Ss][Tt][Aa][Tt][Ss] [Gg][Pp] (-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Tt][Aa][Tt][Ss] [Gg][Pp]) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group is Days*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
	 if is_sudo(msg) then
  -----------------------------------------------------------------------------------------------
  if text:match("^[Ll][Ee][Aa][Vv][Ee] (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^([Ll][Ee][Aa][Vv][Ee]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '*Group* '..txt[2]..' *remov*', 1, 'md')
	   send(txt[2], 0, 1, '*Error*\n_Group is not my_', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  
  if text:match("^ãÛÇÏÑå (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^(ãÛÇÏÑå) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '• `ÇáãÌãæÚå` '..txt[2]..' `Êã ÇáÎÑæÌ ãäåÇ` ????', 1, 'md')
	   send(txt[2], 0, 1, '• `åĞå áíÓÊ Öãä ÇáãÌãæÚÇÊ ÇáÎÇÕÉ Èí` ???', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^ÇáãÏå1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(ÇáãÏå1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '• `ÇáãÌãæÚå` '..txt[2]..' `Êã ÇÚÇÏÉ ÊİÚíáåÇ ÇáãÏÉ 30 íæã ????`', 1, 'md')
	   send(txt[2], 0, 1, '• `Êã ÊİÚíá ãÏÉ ÇáãÌãæÚå 30 íæã` ????', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "• `ŞÇã ÈÊİÚíá ãÌãæÚå ÇáãÏå ßÇäÊ 30 íæã ??` : \n• `ÇíÏí ÇáãØæÑ ??` : "..msg.sender_user_id_.."\n• `ãÚÑİ ÇáãØæÑ ??` : "..get_info(msg.sender_user_id_).."\n\n• `ãÚáæãÇÊ ÇáãÌãæÚå ??` :\n\n• `ÇíÏí ÇáãÌãæÚå ??` : "..msg.chat_id_.."\n• `ÇÓã ÇáãÌãæÚå ??` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 30 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 30 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^ÇáãÏå2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(ÇáãÏå2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '• `ÇáãÌãæÚå` '..txt[2]..' `Êã ÇÚÇÏÉ ÊİÚíáåÇ ÇáãÏÉ 90 íæã ????`', 1, 'md')
	   send(txt[2], 0, 1, '• `Êã ÊİÚíá ãÏÉ ÇáãÌãæÚå 90 íæã` ????', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "• `ŞÇã ÈÊİÚíá ãÌãæÚå ÇáãÏå ßÇäÊ 90 íæã ??` : \n• `ÇíÏí ÇáãØæÑ ??` : "..msg.sender_user_id_.."\n• `ãÚÑİ ÇáãØæÑ ??` : "..get_info(msg.sender_user_id_).."\n\n• `ãÚáæãÇÊ ÇáãÌãæÚå ??` :\n\n• `ÇíÏí ÇáãÌãæÚå ??` : "..msg.chat_id_.."\n• `ÇÓã ÇáãÌãæÚå ??` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
-------------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 90 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 90 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^ÇáãÏå3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(ÇáãÏå3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '• `ÇáãÌãæÚå` '..txt[2]..' `Êã ÇÚÇÏÉ ÊİÚíáåÇ ÇáãÏÉ áÇ äåÇÆíÉ ????`', 1, 'md')
	   send(txt[2], 0, 1, '• `Êã ÊİÚíá ãÏÉ ÇáãÌãæÚå áÇ äåÇÆíÉ` ????', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "• `ŞÇã ÈÊİÚíá ãÌãæÚå ÇáãÏå ßÇäÊ áÇ äåÇÆíÉ ??` : \n• `ÇíÏí ÇáãØæÑ ??` : "..msg.sender_user_id_.."\n• `ãÚÑİ ÇáãØæÑ ??` : "..get_info(msg.sender_user_id_).."\n\n• `ãÚáæãÇÊ ÇáãÌãæÚå ??` :\n\n• `ÇíÏí ÇáãÌãæÚå ??` : "..msg.chat_id_.."\n• `ÇÓã ÇáãÌãæÚå ??` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done Days No Fanil Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done Days No Fanil Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
local text = msg.content_.text_:gsub('ÊİÚíá','add')
  if text:match('^[Aa][Dd][Dd]$') and is_sudo(msg) then
  local keko22 = ''..config2.t..''..config2.keko[19]..':'..config2.keko[1]..''..config2.keko[2]..''..config2.keko[3]..''..config2.keko[4]..''..config2.keko[5]..''..config2.keko[6]..''..config2.keko[7]..''..config2.keko[8]..''..config2.keko[9]..''..config2.keko[10]..''..config2.keko[11]..''..config2.keko[12]..''..config2.keko[13]..''..config2.keko[14]..''..config2.keko[15]..''..config2.keko[16]..''..config2.keko[17]..''..config2.keko[18]..''..config2.t2..''..msg.sender_user_id_..''
  local ress = https.request(keko22)
  local jrees = JSON.decode(ress)
  if jrees.description == 'Bad Request: USER_ID_INVALID' then 
  print(config2.to)
  send(msg.chat_id_, msg.id_, 1, config2.telegram, 1, 'md')
  return false end
  local txt = {string.match(text, "^([Aa][Dd][Dd])$")} 
  if database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already Added Group*', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, "• `ÇáãÌãæÚå [ "..chat.title_.." ] ãİÚáå ÓÇÈŞÇ` ??", 1, 'md')
end
                  end
       if not database:get("bot:charge:"..msg.chat_id_) then
       database:set("bot:charge:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Added To Group*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "• `ÇíÏíß ?? :` _"..msg.sender_user_id_.."_\n• `Êã` ?? `ÊİÚíá ÇáãÌãæÚå [ "..chat.title_.." ]` ??", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> added bot to new group*" , 1, 'md')
      else  
            send(v, 0, 1, "• `ŞÇã ÈÊİÚíá ãÌãæÚå ÌÏíÏå ??` : \n• `ÇíÏí ÇáãØæÑ ??` : "..msg.sender_user_id_.."\n• `ãÚÑİ ÇáãØæÑ ??` : "..get_info(msg.sender_user_id_).."\n\n• `ãÚáæãÇÊ ÇáãÌãæÚå ??` :\n\n• `ÇíÏí ÇáãÌãæÚå ??` : "..msg.chat_id_.."\n• `ÇÓã ÇáãÌãæÚå ??` : "..chat.title_ , 1, 'md')
end
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ÊÚØíá','rem')
  if text:match('^[Rr][Ee][Mm]$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Rr][Ee][Mm])$")} 
      if not database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already remove Group*', 1, 'md')
    else 
        send(msg.chat_id_, msg.id_, 1, "• `ÇáãÌãæÚå [ "..chat.title_.." ] ãÚØáå ÓÇÈŞÇ` ??", 1, 'md')
end
                  end
      if database:get("bot:charge:"..msg.chat_id_) then
       database:del("bot:charge:"..msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Removed To Group!*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "• `ÇíÏíß ?? :` _"..msg.sender_user_id_.."_\n• `Êã` ?? `ÊÚØíá ÇáãÌãæÚå [ "..chat.title_.." ]` ??", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Removed bot from new group*" , 1, 'md')
      else 
            send(v, 0, 1, "• `ŞÇã ÈÊÚØíá ãÌãæÚå ??` : \n• `ÇíÏí ÇáãØæÑ ??` : "..msg.sender_user_id_.."\n• `ãÚÑİ ÇáãØæÑ ??` : "..get_info(msg.sender_user_id_).."\n\n• `ãÚáæãÇÊ ÇáãÌãæÚå ??` :\n\n• `ÇíÏí ÇáãÌãæÚå ??` : "..msg.chat_id_.."\n• `ÇÓã ÇáãÌãæÚå ??` : "..chat.title_ , 1, 'md')
end
       end
  end
  end
              
  -----------------------------------------------------------------------------------------------
   if text:match('^[Jj][Oo][Ii][Nn] (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Jj][Oo][Ii][Nn]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *is join*', 1, 'md')
	   send(txt[2], 0, 1, '*Sudo Joined To Grpup*', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
  -----------------------------------------------------------------------------------------------
   if text:match('^ÇÖÇİå (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(ÇÖÇİå) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '• `ÇáãÌãæÚå` '..txt[2]..' `Êã ÇÖÇİÊß áåÇ ` ??', 1, 'md')
	   send(txt[2], 0, 1, '• `Êã ÇÖÇİå ÇáãØæÑ ááãÌãæÚå` ????', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
   -----------------------------------------------------------------------------------------------
  end
	-----------------------------------------------------------------------------------------------
     if text:match("^[Dd][Ee][Ll]$")  and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^ãÓÍ$") and msg.reply_to_message_id_ ~= 0 and is_mod(msg.sender_user_id_, msg.chat_id_) then
     delete_msg(msg.chat_id_, {[0] = msg.reply_to_message_id_})
     delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
	----------------------------------------------------------------------------------------------
   if text:match('^ÊäÙíİ (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^(ÊäÙíİ) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '• <code> áÇ ÊÓÊØíÚ ÍĞİ ÇßËÑ ãä 100 ÑÓÇáå ????</code>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])}, delmsg, nil)
      pm ='• <i>[ '..matches[2]..' ]</i> <code>ãä ÇáÑÓÇÆá Êã ÍĞİåÇ ???</code>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='• <code> åäÇß ÎØÇ<code> ??'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
              end
            end


   if text:match('^[Dd]el (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^([Dd]el) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '<b>> Error</b>\n<b>use /del [1-1000] !<bb>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
      pm ='> <i>'..matches[2]..'</i> <b>Last Msgs Has Been Removed.</b>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='<b>> found!<b>'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                end
              end

          local text = msg.content_.text_:gsub('ÍİÙ','note')
    if text:match("^[Nn][Oo][Tt][Ee] (.*)$") and is_sudo(msg) then
    local txt = {string.match(text, "^([Nn][Oo][Tt][Ee]) (.*)$")}
      database:set('owner:note1', txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*save!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÍİÙ ÇáßáíÔå ??`', 1, 'md')
end
    end

    if text:match("^[Dd][Nn][Oo][Tt][Ee]$") or text:match("^ÍĞİ ÇáßáíÔå$") and is_sudo(msg) then
      database:del('owner:note1',msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Deleted!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÍĞİ ÇáßáíÔå ??`', 1, 'md')
end
      end
  -----------------------------------------------------------------------------------------------
    if text:match("^[Gg][Ee][Tt][Nn][Oo][Tt][Ee]$") and is_sudo(msg) or text:match("^ÌáÈ ÇáßáíÔå$") and is_sudo(msg) then
    local note = database:get('owner:note1')
	if note then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note is :-*\n'..note, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `ÇáßáíÔå ÇáãÍİæÙå ?? :`\n'..note, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `áÇ íæÌÏ ßáíÔå ãÍİæÙå ??`', 1, 'md')
end
	end
end

  if text:match("^[Ss][Ee][Tt][Ll][Aa][Nn][Gg] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÊÍæíá (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local langs = {string.match(text, "^(.*) (.*)$")}
  if langs[2] == "ar" or langs[2] == "ÚÑÈíå" then
  if not database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '• `ÈÇáİÚá Êã æÖÚ ÇááÛå ÇáÚÑÈíå ááÈæÊ ??`', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã æÖÚ ÇááÛå ÇáÚÑÈíå ááÈæÊ İí ÇáãÌãæÚå ??`', 1, 'md')
       database:del('lang:gp:'..msg.chat_id_)
    end
    end
  if langs[2] == "en" or langs[2] == "ÇäßáíÒíå" then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '_> Language Bot is already_ *English*', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '> _Language Bot has been changed to_ *English* !', 1, 'md')
        database:set('lang:gp:'..msg.chat_id_,true)
    end
    end
end
----------------------------------------------------------------------------------------------

  if text == "unlock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊİÚíá ÑÏæÏ ÇáÈæÊ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already enabled*?', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáÈæÊ ÈÇáİÚá Êã ÊİÚíáåÇ` ??', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been enable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊİÚíá ÑÏæÏ ÇáÈæÊ` ??', 1, 'md')
       database:del('bot:rep:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊÚØíá ÑÏæÏ ÇáÈæÊ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already disabled*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáÈæÊ ÈÇáİÚá Êã ÊÚØíáåÇ` ??', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been disable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚØíá ÑÏæÏ ÇáÈæÊ` ??', 1, 'md')
        database:set('bot:rep:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------

  if text == "unlock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊİÚíá ÑÏæÏ ÇáãØæÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already enabled*?', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáãØæÑ ÈÇáİÚá Êã ÊİÚíáåÇ` ??', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been enable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊİÚíá ÑÏæÏ ÇáãØæÑ` ??', 1, 'md')
       database:del('bot:repsudo:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊÚØíá ÑÏæÏ ÇáãØæÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already disabled*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáãØæÑ ÈÇáİÚá Êã ÊÚØíáåÇ` ??', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been disable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚØíá ÑÏæÏ ÇáãØæÑ` ??', 1, 'md')
        database:set('bot:repsudo:mute'..msg.chat_id_,true)
      end
    end
  end
  
  if text == "unlock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊİÚíá ÑÏæÏ ÇáãÏíÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already enabled*?', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáãÏíÑ ÈÇáİÚá Êã ÊİÚíáåÇ` ??', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been enable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊİÚíá ÑÏæÏ ÇáãÏíÑ` ??', 1, 'md')
       database:del('bot:repowner:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊÚØíá ÑÏæÏ ÇáãÏíÑ" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already disabled*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `ÑÏæÏ ÇáãÏíÑ ÈÇáİÚá Êã ÊÚØíáåÇ` ??', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been disable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚØíá ÑÏæÏ ÇáãÏíÑ` ??', 1, 'md')
        database:set('bot:repowner:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Dd][Gg][Pp]$") or text:match("^ÇíÏí ÇáãÌãæÚå$") then
    send(msg.chat_id_, msg.id_, 1, "*"..msg.chat_id_.."*", 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
  if text == "unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊİÚíá ÇáÇíÏí" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already enabled*?', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '• `ÇáÇíÏí ÈÇáİÚá Êã ÊİÚíáå` ??', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been enable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊİÚíá ÇáÇíÏí` ??', 1, 'md')
       database:del('bot:id:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "ÊÚØíá ÇáÇíÏí" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already disabled*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `ÇáÇíÏí ÈÇáİÚá Êã ÊÚØíáå` ??', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been disable*?', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '• `Êã ÊÚØíá ÇáÇíÏí` ??', 1, 'md')
        database:set('bot:id:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
if  text:match("^[Ii][Dd]$") and msg.reply_to_message_id_ == 0 or text:match("^ÇíÏí$") and msg.reply_to_message_id_ == 0 then
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
      if is_sudo(msg) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Sudo'
      else
      t = 'ãØæÑ ÇáÈæÊ ??'
      end
      elseif is_admin(msg.sender_user_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Global Admin'
      else
      t = 'ÇÏãä İí ÇáÈæÊ ??'
      end
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Owner'
      else
      t = 'ãÏíÑ ÇáßÑæÈ ??'
      end
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'ÇÏãä ááßÑæÈ ??'
      end
      elseif is_vip(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'ÚÖæ ããíÒ??'
      end
      else
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Member'
      else
      t = 'ÚÖæ İŞØ ??'
      end
    end
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"> Group ID : "..msg.chat_id_.."\n> Your ID : "..msg.sender_user_id_.."\n> UserName : "..get_info(msg.sender_user_id_).."\n> Your Rank : "..t.."\n> Msgs : "..user_msgs,msg.id_,msg.id_.."")
  else 
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"• ÇíÏí ÇáãÌãæÚå ?? : "..msg.chat_id_.."\n• ÇíÏíß ?? : "..msg.sender_user_id_.."\n• ãÚÑİß ?? : "..get_info(msg.sender_user_id_).."\n• ãæŞÚß *?? : "..t.."\n• ÑÓÇÆáß ?? : "..user_msgs,msg.id_,msg.id_.."")
end
else 
      end
   else
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!\n\n> *> Group ID :* "..msg.chat_id_.."\n*> Your ID :* "..msg.sender_user_id_.."\n*> UserName :* "..get_info(msg.sender_user_id_).."\n*> Msgs : *_"..user_msgs.."_", 1, 'md')
   else 
      send(msg.chat_id_, msg.id_, 1, "•`ÇäÊ áÇ Êãáß ÕæÑå áÍÓÇÈß ` ??\n\n•` ÇíÏí ÇáãÌãæÚå ` ?? : "..msg.chat_id_.."\n•` ÇíÏíß ` ?? : "..msg.sender_user_id_.."\n•` ãÚÑİß ` ?? : "..get_info(msg.sender_user_id_).."\n•` ÑÓÇÆáß `?? : _"..user_msgs.."_", 1, 'md')
end
else 
      end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
end

   if text:match('^ÇáÍÓÇÈ (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^ÇáÍÓÇÈ (%d+)$')
        local text = 'ÇÖÛØ áãÔÇåÏå ÇáÍÓÇÈ'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end 

   if text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$')
        local text = 'Click to view user!'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end
          local text = msg.content_.text_:gsub('ãÚáæãÇÊ','res')
          if text:match("^[Rr][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([Rr][Ee][Ss]) (.*)$")}
            function whois(extra,result,success)
                if result.username_ then
             result.username_ = '@'..result.username_
               else
             result.username_ = 'áÇ íæÌÏ ãÚÑİ'
               end
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> *Name* :'..result.first_name_..'\n> *Username* : '..result.username_..'\n> *ID* : '..msg.sender_user_id_, 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '• `ÇáÇÓã` ?? : '..result.first_name_..'\n• `ÇáãÚÑİ` ?? : '..result.username_..'\n• `ÇáÇíÏí` ?? : '..msg.sender_user_id_, 1, 'md')
              end
            end
            getUser(memb[2],whois)
          end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÊËÈíÊ$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
	            send(msg.chat_id_, msg.id_, 1, '_Msg han been_ *pinned!*', 1, 'md')
	           else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÊËÈíÊ ÇáÑÓÇáå` ??', 1, 'md')
end
 end

   if text:match("^[Vv][Ii][Ee][Ww]$") or text:match("^ãÔÇåÏå ãäÔæÑ$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
    if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*Please send a post now!*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '• `Şã ÈÇÑÓÇá ÇáãäÔæÑ ÇáÇä` ??', 1, 'md')
end
   end
  end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Uu][Nn][Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáÛÇÁ ÊËÈíÊ$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^ÇáÛÇÁ ÇáÊËÈíÊ") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Pinned Msg han been_ *unpinned!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '• `Êã ÇáÛÇÁ ÊËÈíÊ ÇáÑÓÇáå` ??', 1, 'md')
end
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Hh][Ee][Ll][Pp]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
`åäÇß`  *6* `ÇæÇãÑ áÚÑÖåÇ`
*======================*
*h1* `áÚÑÖ ÇæÇãÑ ÇáÍãÇíå`
*======================*
*h2* `áÚÑÖ ÇæÇãÑ ÇáÍãÇíå ÈÇáÊÍĞíÑ`
*======================*
*h3* `áÚÑÖ ÇæÇãÑ ÇáÍãÇíå ÈÇáØÑÏ`
*======================*
*h4* `áÚÑÖ ÇæÇãÑ ÇáÇÏãäíå`
*======================*
*h5* `áÚÑÖ ÇæÇãÑ ÇáãÌãæÚå`
*======================*
*h6* `áÚÑÖ ÇæÇãÑ ÇáãØæÑíä`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ááŞİá`
*unlock* `ááİÊÍ`
*======================*
*| links |* `ÇáÑæÇÈØ`
*| tag |* `ÇáãÚÑİ`
*| hashtag |* `ÇáÊÇß`
*| cmd |* `ÇáÓáÇÔ`
*| edit |* `ÇáÊÚÏíá`
*| webpage |* `ÇáÑæÇÈØ ÇáÎÇÑÌíå`
*======================*
*| flood ban |* `ÇáÊßÑÇÑ ÈÇáØÑÏ`
*| flood mute |* `ÇáÊßÑÇÑ ÈÇáßÊã`
*| flood del |* `ÇáÊßÑÇÑ ÈÇáãÓÍ`
*| gif |* `ÇáÕæÑ ÇáãÊÍÑßå`
*| photo |* `ÇáÕæÑ`
*| sticker |* `ÇáãáÕŞÇÊ`
*| video |* `ÇáİíÏíæ`
*| inline |* `áÓÊÇÊ ÔİÇİå`
*======================*
*| text |* `ÇáÏÑÏÔå`
*| fwd |* `ÇáÊæÌíå`
*| music |* `ÇáÇÛÇäí`
*| voice |* `ÇáÕæÊ`
*| contact |* `ÌåÇÊ ÇáÇÊÕÇá`
*| service |* `ÇÔÚÇÑÇÊ ÇáÏÎæá`
*| markdown |* `ÇáãÇÑßÏæä`
*| file |* `ÇáãáİÇÊ`
*======================*
*| location |* `ÇáãæÇŞÚ`
*| bots |* `ÇáÈæÊÇÊ`
*| spam |* `ÇáßáÇíÔ`
*| arabic |* `ÇáÚÑÈíå`
*| english |* `ÇáÇäßáíÒíå`
*| reply bot |* `ÑÏæÏ ÇáÈæÊ`
*| reply sudo |* `ÑÏæÏ ÇáãØæÑ`
*| reply owner |* `ÑÏæÏ ÇáãÏíÑ`
*| id |* `ÇáÇíÏí`
*| all |* `ßá ÇáãíÏíÇ`
*| all |* `ãÚ ÇáÚÏÏ Şİá ÇáãíÏíÇ ÈÇáËæÇäí`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ááŞİá`
*unlock* `ááİÊÍ`
*======================*
*| links warn |* `ÇáÑæÇÈØ`
*| tag warn |* `ÇáãÚÑİ`
*| hashtag warn |* `ÇáÊÇß`
*| cmd warn |* `ÇáÓáÇÔ`
*| webpage warn |* `ÇáÑæÇÈØ ÇáÎÇÑÌíå`
*======================*
*| gif warn |* `ÇáÕæÑ ÇáãÊÍÑßå`
*| photo warn |* `ÇáÕæÑ`
*| sticker warn |* `ÇáãáÕŞÇÊ`
*| video warn |* `ÇáİíÏíæ`
*| inline warn |* `áÓÊÇÊ ÔİÇİå`
*======================*
*| text warn |* `ÇáÏÑÏÔå`
*| fwd warn |* `ÇáÊæÌíå`
*| music warn |* `ÇáÇÛÇäí`
*| voice warn |* `ÇáÕæÊ`
*| contact warn |* `ÌåÇÊ ÇáÇÊÕÇá`
*| markdown warn |* `ÇáãÇÑßÏæä`
*| file warn |* `ÇáãáİÇÊ`
*======================*
*| location warn |* `ÇáãæÇŞÚ`
*| spam |* `ÇáßáÇíÔ`
*| arabic warn |* `ÇáÚÑÈíå`
*| english warn |* `ÇáÇäßáíÒíå`
*| all warn |* `ßá ÇáãíÏíÇ`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `ááŞİá`
*unlock* `ááİÊÍ`
*======================*
*| links ban |* `ÇáÑæÇÈØ`
*| tag ban |* `ÇáãÚÑİ`
*| hashtag ban |* `ÇáÊÇß`
*| cmd ban |* `ÇáÓáÇÔ`
*| webpage ban |* `ÇáÑæÇÈØ ÇáÎÇÑÌíå`
*======================*
*| gif ban |* `ÇáÕæÑ ÇáãÊÍÑßå`
*| photo ban |* `ÇáÕæÑ`
*| sticker ban |* `ÇáãáÕŞÇÊ`
*| video ban |* `ÇáİíÏíæ`
*| inline ban |* `áÓÊÇÊ ÔİÇİå`
*| markdown ban |* `ÇáãÇÑßÏæä`
*| file ban |* `ÇáãáİÇÊ`
*======================*
*| text ban |* `ÇáÏÑÏÔå`
*| fwd ban |* `ÇáÊæÌíå`
*| music ban |* `ÇáÇÛÇäí`
*| voice ban |* `ÇáÕæÊ`
*| contact ban |* `ÌåÇÊ ÇáÇÊÕÇá`
*| location ban |* `ÇáãæÇŞÚ`
*======================*
*| arabic ban |* `ÇáÚÑÈíå`
*| english ban |* `ÇáÇäßáíÒíå`
*| all ban |* `ßá ÇáãíÏíÇ`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*| setmote |* `ÑİÚ ÇÏãä` 
*| remmote |* `ÇÒÇáå ÇÏãä` 
*| setvip |* `ÑİÚ ÚÖæ ããíÒ` 
*| remvip |* `ÇÒÇáå ÚÖæ ããíÒ` 
*| setlang en |* `ÊÛíÑ ÇááÛå ááÇäßáíÒíå` 
*| setlang ar |* `ÊÛíÑ ÇááÛå ááÚÑÈíå` 
*| unsilent |* `áÇáÛÇÁ ßÊã ÇáÚÖæ` 
*| silent |* `áßÊã ÚÖæ` 
*| ban |* `ÍÙÑ ÚÖæ` 
*| unban |* `ÇáÛÇÁ ÍÙÑ ÇáÚÖæ` 
*| kick |* `ØÑÏ ÚÖæ` 
*| id |* `áÇÙåÇÑ ÇáÇíÏí [ÈÇáÑÏ] `
*| pin |* `ÊËÈíÊ ÑÓÇáå!`
*| unpin |* `ÇáÛÇÁ ÊËÈíÊ ÇáÑÓÇáå!`
*| res |* `ãÚáæãÇÊ ÍÓÇÈ ÈÇáÇíÏí` 
*| whois |* `ãÚ ÇáÇíÏí áÚÑÖ ÕÇÍÈ ÇáÇíÏí`
*======================*
*| s del |* `ÇÙåÇÑ ÇÚÏÇÏÇÊ ÇáãÓÍ`
*| s warn |* `ÇÙåÇÑ ÇÚÏÇÏÇÊ ÇáÊÍĞíÑ`
*| s ban |* `ÇÙåÇÑ ÇÚÏÇÏÇÊ ÇáØÑÏ`
*| silentlist |* `ÇÙåÇÑ ÇáãßÊæãíä`
*| banlist |* `ÇÙåÇÑ ÇáãÍÙæÑíä`
*| modlist |* `ÇÙåÇÑ ÇáÇÏãäíå`
*| viplist |* `ÇÙåÇÑ ÇáÇÚÖÇÁ ÇáããíÒíä`
*| del |* `ÍĞİ ÑÓÇáå ÈÇáÑÏ`
*| link |* `ÇÙåÇÑ ÇáÑÇÈØ`
*| rules |* `ÇÙåÇÑ ÇáŞæÇäíä`
*======================*
*| bad |* `ãäÚ ßáãå` 
*| unbad |* `ÇáÛÇÁ ãäÚ ßáãå` 
*| badlist |* `ÇÙåÇÑ ÇáßáãÇÊ ÇáããäæÚå` 
*| stats |* `áãÚÑİå ÇíÇã ÇáÈæÊ`
*| del wlc |* `ÍĞİ ÇáÊÑÍíÈ` 
*| set wlc |* `æÖÚ ÇáÊÑÍíÈ` 
*| wlc on |* `ÊİÚíá ÇáÊÑÍíÈ` 
*| wlc off |* `ÊÚØíá ÇáÊÑÍíÈ` 
*| get wlc |* `ãÚÑİå ÇáÊÑÍíÈ ÇáÍÇáí` 
*| add rep |* `ÇÖÇİå ÑÏ` 
*| rem rep |* `ÍĞİ ÑÏ` 
*| rep owner list |* `ÇÙåÇÑ ÑÏæÏ ÇáãÏíÑ` 
*| clean rep owner |* `ãÓÍ ÑÏæ ÇáãÏíÑ` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^[Hh]5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*clean* `ãÚ ÇáÇæÇãÑ ÇÏäÇå ÈæÖÚ İÑÇÛ`
*| banlist |* `ÇáãÍÙæÑíä`
*| badlist |* `ßáãÇÊ ÇáãÍÙæÑå`
*| modlist |* `ÇáÇÏãäíå`
*| viplist |* `ÇáÇÚÖÇÁ ÇáããíÒíä`
*| link |* `ÇáÑÇÈØ ÇáãÍİæÙ`
*| silentlist |* `ÇáãßÊæãíä`
*| bots |* `ÈæÊÇÊ ÊİáíÔ æÛíÑåÇ`
*| rules |* `ÇáŞæÇäíä`
*======================*
*set* `ãÚ ÇáÇæÇãÑ ÇÏäÇå ÈÏæä İÑÇÛ`
*| link |* `áæÖÚ ÑÇÈØ`
*| rules |* `áæÖÚ ŞæÇäíä`
*| name |* `ãÚ ÇáÇÓã áæÖÚ ÇÓã`
*| photo |* `áæÖÚ ÕæÑå`
*======================*
*| flood ban |* `æÖÚ ÊßÑÇÑ ÈÇáØÑÏ`
*| flood mute |* `æÖÚ ÊßÑÇÑ ÈÇáßÊã`
*| flood del |* `æÖÚ ÊßÑÇÑ ÈÇáßÊã`
*| flood time |* `áæÖÚ Òãä ÊßÑÇÑ ÈÇáØÑÏ Çæ ÇáßÊã`
*| spam del |* `æÖÚ ÚÏÏ ÇáÓÈÇã ÈÇáãÓÍ`
*| spam warn |* `æÖÚ ÚÏÏ ÇáÓÈÇã ÈÇáÊÍĞíÑ`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]6$") and is_sudo(msg) then
   
   local text =  [[
*======================*
*| add |* `ÊİÚíá ÇáÈæÊ`
*| rem |* `ÊÚØíá ÇáÈæÊ`
*| setexpire |* `æÖÚ ÇíÇã ááÈæÊ`
*| stats gp |* `áãÚÑİå ÇíÇã ÇáÈæÊ`
*| plan1 + id |* `ÊİÚíá ÇáÈæÊ 30 íæã`
*| plan2 + id |* `ÊİÚíá ÇáÈæÊ 90 íæã`
*| plan3 + id |* `ÊİÚíá ÇáÈæÊ áÇ äåÇÆí`
*| join + id |* `áÇÖÇİÊß ááßÑæÈ`
*| leave + id |* `áÎÑæÌ ÇáÈæÊ`
*| leave |* `áÎÑæÌ ÇáÈæÊ`
*| stats gp + id |* `áãÚÑİå  ÇíÇã ÇáÈæÊ`
*| view |* `áÇÙåÇÑ ãÔÇåÏÇÊ ãäÔæÑ`
*| note |* `áÍİÙ ßáíÔå`
*| dnote |* `áÍĞİ ÇáßáíÔå`
*| getnote |* `áÇÙåÇÑ ÇáßáíÔå`
*| reload |* `áÊäÔíØ ÇáÈæÊ`
*| clean gbanlist |* `áÍĞİ ÇáÍÙÑ ÇáÚÇã`
*| clean owners |* `áÍĞİ ŞÇÆãå ÇáãÏÑÇÁ`
*| adminlist |* `áÇÙåÇÑ ÇÏãäíå ÇáÈæÊ`
*| gbanlist |* `áÇÙåÇÑ ÇáãÍÙæÑíä ÚÇã `
*| ownerlist |* `áÇÙåÇÑ ãÏÑÇÁ ÇáÈæÊ`
*| setadmin |* `áÇÖÇİå ÇÏãä`
*| remadmin |* `áÍĞİ ÇÏãä`
*| setowner |* `áÇÖÇİå ãÏíÑ`
*| remowner |* `áÍĞİ ãÏíÑ`
*| banall |* `áÍÙÑ ÇáÚÇã`
*| unbanall |* `áÇáÛÇÁ ÇáÚÇã`
*| invite |* `áÇÖÇİå ÚÖæ`
*| groups |* `ÚÏÏ ßÑæÈÇÊ ÇáÈæÊ`
*| bc |* `áäÔÑ ÔÆ`
*| del |* `æíå ÇáÚÏÏ ÍĞİ ÑÓÇÆá`
*| add sudo |* `ÇÖİ ãØæÑ`
*| rem sudo |* `ÍĞİ ãØæÑ`
*| add rep all |* `ÇÖİ ÑÏ áßá ÇáãÌãæÚÇÊ`
*| rem rep all |* `ÍĞİ ÑÏ áßá ÇáãÌãæÚÇÊ`
*| change ph |* `ÊÛíÑ Ìåå ÇáãØæÑ`
*| sudo list |* `ÇÙåÇÑ ÇáãØæÑíä` 
*| rep sudo list |* `ÇÙåÇÑ ÑÏæÏ ÇáãØæÑ` 
*| clean sudo |* `ãÓÍ ÇáãØæÑíä` 
*| clean rep sudo |* `ãÓÍ ÑÏæÏ ÇáãØæÑ` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   
   
   if text:match("^ÇáÇæÇãÑ$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• åäÇß  6 ÇæÇãÑ áÚÑÖåÇ ????
? • • • • • • • • • • • • • ?
• `ã1 : áÚÑÖ ÇæÇãÑ ÇáÍãÇíå` ??
• `ã2 : áÚÑÖ ÇæÇãÑ ÇáÍãÇíå ÈÇáÊÍĞíÑ` ??
• `ã3 : áÚÑÖ ÇæÇãÑ ÇáÍãÇíå ÈÇáØÑÏ` ??
• `ã4 : áÚÑÖ ÇæÇãÑ ÇáÇÏãäíå` ??
• `ã5 : áÚÑÖ ÇæÇãÑ ÇáãÌãæÚå `??
• `ã6 : áÚÑÖ ÇæÇãÑ ÇáãØæÑíä `??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^ã1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• ÇæÇãÑ ÍãÇíå ÈÇáãÓÍ  ??
? • • • • • • • • • • • • • ?
• Şİá : áŞİá ÇãÑ ??
• İÊÍ : áİÊÍ ÇãÑ??
? • • • • • • • • • • • • • ?
• ÇáÑæÇÈØ  | ??
• ÇáãÚÑİ |??
• ÇáÊÇß |??
• ÇáÔÇÑÍå |?
• ÇáÊÚÏíá | ??
• ÇáÊËÈíÊ | ??
• ÇáãæÇŞÚ | ??
? • • • • • • • • • • • • • ?
• ÇáÊßÑÇÑ ÈÇáØÑÏ |??
• ÇáÊßÑÇÑ ÈÇáßÊÜã |??
• ÇáÊßÑÇÑ ÈÇáãÓÍ |??
• ÇáãÊÍÑßå |??
• ÇáãáİÇÊ |??
• ÇáÕæÑ |??
• ÇáãáÕŞÇÊ |??
• ÇáİíÏíæ |??
• ÇáÇäáÇíä |??
? • • • • • • • • • • • • • ?
• ÇáÏÑÏÔå |??
• ÇáÊæÌíå |??
• ÇáÇÛÇäí |??
• ÇáÕæÊ |??
• ÇáÌåÇÊ |??
• ÇáãÇÑßÏæä | ?
• ÇáÇÔÚÇÑÇÊ |??
? • • • • • • • • • • • • • ?
• ÇáÔÈßÇÊ |??
• ÇáÈæÊÇÊ |??
• ÇáßáÇíÔ |??
• ÇáÚÑÈíå|??
• ÇáÇäßáíÒíå |??
• Çáßá |??
• Çáßá ÈÇáËæÇäí + ÇáÚÏÏ |??
• Çáßá ÈÇáÓÇÚå + ÇáÚÏÏ |??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
    
   if text:match("^ã2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• ÇæÇãÑ ÍãÇíå ÇáãÌãæÚå ÈÇáÊÍĞíÑ ??
? • • • • • • • • • • • • • ?
Şİá : áŞİá ÇãÑ ??
İÊÍ : áİÊÍ ÇãÑ ??
? • • • • • • • • • • • • • ?
• ÇáÑæÇÈØ ÈÇáÊÍĞíÑ  | ??
• ÇáãÚÑİ ÈÇáÊÍĞíÑ |??
• ÇáÊÇß ÈÇáÊÍĞíÑ |??
• ÇáãÇÑßÏæä ÈÇáÊÍĞíÑ| ?
• ÇáÔÇÑÍå ÈÇáÊÍĞíÑ |?
• ÇáãæÇŞÚ ÈÇáÊÍĞíÑ | ??
• ÇáÊËÈíÊ ÈÇáÊÍĞíÑ | ??
? • • • • • • • • • • • • • ?
• ÇáãÊÍÑßå ÈÇáÊÍĞíÑ |??
• ÇáÕæÑ ÈÇáÊÍĞíÑ |??
• ÇáãáÕŞÇÊ ÈÇáÊÍĞíÑ |??
• ÇáİíÏíæ ÈÇáÊÍĞíÑ |??
• ÇáÇäáÇíä ÈÇáÊÍĞíÑ |??
? • • • • • • • • • • • • • ?
• ÇáÏÑÏÔå ÈÇáÊÍĞíÑ |??
• ÇáãáİÇÊ ÈÇáÊÍĞíÑ |??
• ÇáÊæÌíå ÈÇáÊÍĞíÑ |??
• ÇáÇÛÇäí ÈÇáÊÍĞíÑ |??
• ÇáÕæÊ ÈÇáÊÍĞíÑ |??
• ÇáÌåÇÊ ÈÇáÊÍĞíÑ |??
? • • • • • • • • • • • • • ?
• ÇáÔÈßÇÊ ÈÇáÊÍĞíÑ |??
• ÇáßáÇíÔ ÈÇáÊÍĞíÑ |??
• ÇáÚÑÈíå ÈÇáÊÍĞíÑ |??
• ÇáÇäßáíÒíå ÈÇáÊÍĞíÑ |??
• Çáßá ÈÇáÊÍĞíÑ |??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^ã3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• ÇæÇãÑ ÇáÍãÇíå ÈÇáØÑÏ ??
? • • • • • • • • • • • • • ?
Şİá  : áŞİá ÇãÑ ??
İÊÍ : áİÊÍ ÇãÑ??
? • • • • • • • • • • • • • ?
• ÇáÑæÇÈØ ÈÇáØÑÏ | ??
• ÇáãÚÑİ ÈÇáØÑÏ |??
• ÇáÊÇß ÈÇáØÑÏ |??
• ÇáÔÇÑÍå ÈÇáØÑÏ |?
• ÇáãæÇŞÚ ÈÇáØÑÏ | ??
• ÇáãÇÑßÏæä ÈÇáØÑÏ | ?
? • • • • • • • • • • • • • ?
• ÇáãÊÍÑßå ÈÇáØÑÏ |??
• ÇáãáİÇÊ ÈÇáØÑÏ |??
• ÇáÕæÑ ÈÇáØÑÏ |??
• ÇáãáÕŞÇÊ ÈÇáØÑÏ |??
• ÇáİíÏíæ ÈÇáØÑÏ |??
• ÇáÇäáÇíä ÈÇáØÑÏ  |??
? • • • • • • • • • • • • • ?
• ÇáÏÑÏÔå ÈÇáØÑÏ |??
• ÇáÊæÌíå ÈÇáØÑÏ |??
• ÇáÇÛÇäí ÈÇáØÑÏ |??
• ÇáÕæÊ ÈÇáØÑÏ |??
• ÇáÌåÇÊ ÈÇáØÑÏ|??
• ÇáÔÈßÇÊ ÈÇáØÑÏ|??
? • • • • • • • • • • • • • ?
• ÇáßáÇíÔ ÈÇáØÑÏ |??
• ÇáÚÑÈíå ÈÇáØÑÏ  |??
• ÇáÇäßáíÒíå ÈÇáØÑÏ |??
• Çáßá ÈÇáØÑÏ |??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^ã4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• ÇæÇãÑ ÇáÇÏãäíå ??
? • • • • • • • • • • • • • ?
• ÑİÚ ÇÏãä | ??
• ÊäÒíá ÇÏãä | ??
• ÑİÚ ÚÖæ ããíÒ | ?
• ÊäÒíá ÚÖæ ããíÒ | ?
• ÊÍæíá ÇäßáíÒíå | ??
• ÊÍæíá ÚÑÈíå | ??
• ÇíÏí + ÑÏ | ??
• ÇáÛÇÁ ßÊã | ??
• ßÊã | ??
• ÍÙÑ | ??
• ØÑÏ | ??
• ÇáÛÇÁ ÍÙÑ | ??
• ÊËÈíÊ | ??
• ÇáÛÇÁ ÊËÈíÊ | ?
? • • • • • • • • • • • • • ?
• ÇÚÏÇÏÇÊ ÇáãÓÍ | ??
• ÇÚÏÇÏÇÊ ÇáÊÍĞíÑ | ??
• ÇÚÏÇÏÇÊ ÇáØÑÏ | ??
• ÇáãßÊæãíä | ??
• ÇáãÍÙæÑíä | ??
• ŞÇÆãå ÇáãäÚ | ??
• ÇáÇÚÖÇÁ ÇáããíÒíä | ??
• ÇáÇÏãäíå | ??
• ãÓÍ + ÑÏ | ??
• ÇáÑÇÈØ | ??
• ÇáŞæÇäíä | ??
? • • • • • • • • • • • • • ?
• ÇÖİ ÑÏ | ??
• ÍĞİ ÑÏ | ??
• ãäÚ + Çáßáãå | ??
• ÇáÛÇÁ ãäÚ + Çáßáãå| ??
• ÇáæŞÊ |??
• ÍĞİ ÇáÊÑÍíÈ | ??
• æÖÚ ÊÑÍíÈ | ??
• ÊİÚíá ÇáÊÑÍíÈ | ??
• ÊÚØíá ÇáÊÑÍíÈ | ?
• ÌáÈ ÇáÊÑÍíÈ | ??
				
• ÊİÚíá ÑÏæÏ ÇáÈæÊ  | ??
• ÊÚØíá ÑÏæÏ ÇáÈæÊ |??
• ÊİÚíá ÑÏæÏ ÇáãÏíÑ  | ?
• ÊÚØíá ÑÏæÏ ÇáãÏíÑ |? 
• ÊİÚíá ÑÏæÏ ÇáãØæÑ | ??
• ÊÚØíá ÑÏæÏ ÇáãØæÑ | ??
• ÑÏæÏ ÇáãÏíÑ |?
• ãÓÍ ÑÏæÏ ÇáãÏíÑ |??
• ÊİÚíá ÇáÇíÏí  | ??
• ÊÚØíá ÇáÇíÏí |??
• ãÚáæãÇÊ + ÇíÏí|??
• ÇáÍÓÇÈ + ÇíÏí| ??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^ã5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
• ÇæÇãÑ ÇáãÌãæÚå ??
? • • • • • • • • • • • • • ?
ãÓÍ : ãÚ ÇáÇæÇãÑ ÇÏäÇå ÈæÖÚ İÑÇÛ
? • • • • • • • • • • • • • ?
• ÇáãÍÙæÑíä | ??
• ŞÇÆãå ÇáãäÚ | ??
• ÇáÇÏãäíå | ??
• ÇáÇÚÖÇÁ ÇáããíÒíä | ??
• ÇáÑÇÈØ | ??
• ÇáãßÊæãíä | ??
• ÇáÈæÊÇÊ | ??
• ÇáŞæÇäíä | ??
? • • • • • • • • • • • • • ?
æÖÚ : ãÚ ÇáÇæÇãÑ ÇÏäÇå
? • • • • • • • • • • • • • ?
• ÑÇÈØ | ??
• ŞæÇäíä | ??
• ÇÓã | ??
• ÕæÑå | ??
? • • • • • • • • • • • • • ?
• æÖÚ ÊßÑÇÑ ÈÇáØÑÏ + ÇáÚÏÏ| ??
• æÖÚ ÊßÑÇÑ ÈÇáßÊã + ÇáÚÏÏ| ??
• æÖÚ ÊßÑÇÑ ÈÇáãÓÍ + ÇáÚÏÏ| ??
• æÖÚ Òãä ÇáÊßÑÇÑ + ÇáÚÏÏ| ??
• æÖÚ ßáÇíÔ ÈÇáãÓÍ + ÇáÚÏÏ| ??
• æÖÚ ßáÇíÔ ÈÇáÊÍĞíÑ + ÇáÚÏÏ| ??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^ã6$") and is_sudo(msg) then
   
   local text =  [[
• ÇæÇãÑ ÇáãØæÑ ????
? • • • • • • • • • • • • • ?
• ÊİÚíá | ??
• ÊÚØíá | ?
• æÖÚ æŞÊ + ÚÏÏ | ??
• ÇáãÏå1 + id | ??
• ÇáãÏå2 + id |?
• ÇáãÏå3 + id | ??
• ÇÖÇİå + id | ??
• ãÛÇÏÑå + id | ??
• ãÛÇÏÑå | ??
? • • • • • • • • • • • • • ?
• æŞÊ ÇáãÌãæÚå + id | ??
• ãÔÇåÏå ãäÔæÑ | ??
• ÍİÙ | ??
• ÍĞİ ÇáßáíÔå | ??
• ÌáÈ ÇáßáíÔå | ??
• ÊÍÏíË | ??
• ãÓÍ ŞÇÆãå ÇáÚÇã | ??
• ãÓÍ ÇáãÏÑÇÁ | ??
• ÇÏãäíå ÇáÈæÊ | ??
• ŞÇÆãå ÇáÚÇã | ??
• ÇáãÏÑÇÁ | ??
• ÑİÚ ÇÏãä ááÈæÊ | ??
• ÊäÒíá ÇÏãä ááÈæÊ | ??
? • • • • • • • • • • • • • ?
• ÑİÚ ãÏíÑ | ??
• ÊäÒíá ãÏíÑ | ??
• ÍÙÑ ÚÇã | ??
• ÇáÛÇÁ ÇáÚÇã | ??
• ÇáßÑæÈÇÊ | ??
• ÇÖÇİå | ?
• ÇĞÇÚå + ßáíÔå | ??
• ÊäÙíİ + ÚÏÏ | ??
• ÇÖİ ãØæÑ | ?
• ÍĞİ ãØæÑ |?
• ÇáãØæÑíä |??
• ãÓÍ ÇáãØæÑíä |??
• ÑÏæÏ ÇáãØæÑ |??
• ãÓÍ ÑÏæÏ ÇáãØæÑ |??
• ÊÛíÑ ÇãÑ ÇáãØæÑ |??
• ÇÖİ ÑÏ ááßá |??
• ÍĞİ ÑÏ ááßá | ??
? • • • • • • • • • • • • • ?
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
if text:match("^source$") or text:match("^ÇÕÏÇÑ$") or text:match("^ÇáÇÕÏÇÑ$") or text:match("^ÇáÓæÑÓ$") or text:match("^ÓæÑÓ$") then
   
   local text =  [[
• <code>ÇåáÇ Èß İí ÓæÑÓ ÊÔÇßí</code> ???
• <code>ÇáãØæÑíä</code> ??:-
• <b>TshAkE TEAM </b>
• <code>ŞäÇå ÇáÓæÑÓ</code> ??:-
•<b> Channel</b> | @lTSHAKEl_CH
• <code>ÑÇÈØ Github cli </code>??:-
• https://github.com/moodlIMyIl/TshAkE
• <code>ÑÇÈØ Github api </code>??:-
• https://github.com/moodlIMyIl/TshAkEapi
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end

if text:match("^ÇÑíÏ ÑÇÈØ ÍĞİ$") or text:match("^ÑÇÈØ ÍĞİ$") or text:match("^ÑÇÈØ ÇáÍĞİ$") or text:match("^ÇáÑÇÈØ ÍĞİ$") or text:match("^ÇÑíÏ ÑÇÈØ ÇáÍĞİ$") then
   
   local text =  [[
• ÑÇÈØ ÍĞİ ÇáÊáí ?? ?
• ÇÍĞİ æáÇ ÊÑÌÚ ÚíÔ ÍíÇÊß ?????
• https://telegram.org/deactivate
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
  -----------------------------------------------------------------------------------------------
 end
  -----------------------------------------------------------------------------------------------
                                       -- end code --
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end

   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
   if database:get('bot:links:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá ááÑæÇÈØ</code> ??", 1, 'html')
	end
end
end

	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	
   if database:get('bot:webpage:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá ááãæÇŞÚ</code> ??", 1, 'html')
	end
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:tag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá ááãÚÑİÇÊ</code> ??", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:hashtag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá ááÊÇßÇÊ</code> ??", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("/")  then
   if database:get('bot:cmd:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:cmd:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá ááÔÇÑÍå</code> ??", 1, 'html')
	end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	end
	   if database:get('bot:arabic:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá  ááÛå ÇáÚÑÈíå</code> ??", 1, 'html')
	end
 end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:english:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "• <code>ããäæÚ Úãá ÊÚÏíá  ááÛå ÇáÇäßáíÒíå</code> ??", 1, 'html')
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
              send(msg.chat_id_, 0, 1, "• <code>ããäæÚ ÇáÊÚÏíá åäÇ</code> ??", 1, 'html')
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
     send(msg.chat_id_, msg.message_id_, 1, '• `áŞÏ ŞãÊ ÈÇáÊÚÏíá` ?\n\n•`ÑÓÇáÊß ÇáÓÇÈŞå ` ??  : \n\n• [ '..old_text..' ]', 1, 'md')
	end
end 
end
end
    end
	end

    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
  -----------------------------------------------------------------------------------------------
end

--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @TshAkETEAM
--]]