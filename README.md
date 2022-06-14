# Telegram sessions storage
This module is a broker between SIP.tg platform and your Telegram account in SIP Gateway mode. It allows to locate your Telegram session data on your hardware and pass only white-listed operations with your Telegram account. This approach reaches two main goals:
- decreases risks of compromising your Telegram account: SIP.tg gets a limited access to your Telegram account;
- SIP.tg remains usable: management of SIP Gateway is made through [@siptg_bot](https://t.me/siptg_bot).

The storage uses TDLib library as a backend to communicate with Telegram platform and acts as TCP server for SIP.tg platform. It caches and resolves usernames and phone numbers into user_ids _out of the box_ and optionally can backup all data into MySQL database. It also allows to connect to the Telegram session from multiple socket clients.

## How to configure the storage
Update the software of your system. For example, on Ubuntu/Debian system use the following commands:
```
apt-get update
apt-get upgrade
```

Next, setup docker and download latest configs:
```
cd ~
wget get.docker.com -O - -o /dev/null | sudo sh
apt-get install docker-compose dnsutils git
git clone https://github.com/siptg/storage.git
cd storage
```

Get `API_ID` and `API_HASH` through [API development tools](https://my.telegram.org/apps) and update them in `storage/settings.json` in section `tdlib`.

Get the `cert.pem` and `key.pem` from the [@siptg_bot](https://t.me/siptg_bot) and push it to `ssl` directory inside `storage`.

> **Warning!** The certificate which is given from the bot is valid for a limited time (365 days at the moment). In the case it expires, you get **Certificate error** while connecting to the storage and have to get the new one the same way. To check the expiration date use the following command:  
`openssl x509 -enddate -noout -in ssl/cert.pem`

Next, verify and change if needed the storage's server port which will be used to connect to your storage from SIP.tg platform (see [below](#default-ports-which-are-used-by-the-storage)). If you are is under the NAT, verify the port mapping at the NAT as well. Also don't forget to allow incoming connections for the specified port at your firewall if needed.

Next, run the storage by command:
```
docker-compose up -d storage nginx
```

After that set the host's `address:port` in the bot and push `Turn on` button. You're done!

## Default ports which are used by the storage
| Port   	| Type 	| Area  	| Description            	| To change                                                                         	|
|--------	|------	|-------	|------------------------	|-----------------------------------------------------------------------------------	|
| 50002* 	| TCP  	| all   	| Storage external       	| nginx/nginx.conf: `stream`→`server`→`listen`                                      	|
| 23456  	| TCP  	| local 	| Storage internal       	| storage/settings.json: `port`<br>nginx/nginx.conf: `stream`→`server`→`proxy_pass` 	|

\* — the port which you have to provide to the bot.

## Managing the storage
### Restart
Inside `storage` directory run:
```
docker-compose restart storage
```

### Update
Inside `storage` directory run:
```
git pull
docker-compose pull storage && docker-compose up -d storage
```

## Settings file
Settings file is located on `storage/settings.json` and has JSON format with the following options:

| Option                	| Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                           	|  Default  	|
|-----------------------	|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|:---------:	|
| logfile               	| If set, redirect stderr and stdout to the specified file. Please note: it requires to attach [external volume](https://docs.docker.com/compose/compose-file/#volumes) from the `docker-compose.yml`, make an empty file with the given logfile name and [update](#update) the storage first.                                                                                                                                                                                          	| (not set) 	|
| debug_level           	| Main debug level:<br>0 - NONE: output only version info;<br>1 - FATAL: add errors which terminates the storages;<br>2 - ERROR: add general errors;<br>3 - WARNING: add attempts of disallowed RPC calls;<br>4 - INFO: general info about start/stop Telegram sessions;<br>5 - DEBUG: debug info about create/destroy internal structures;<br>6 - VERBOSE: output data of RPC/updates attempts.                                                                                        	| 4         	|
| terminate_delay       	| Delay (in seconds) before terminating Telegram session after the last socket client is disconnected                                                                                                                                                                                                                                                                                                                                                                                   	| 0         	|
| host                  	| IP address or host where the server starts listening                                                                                                                                                                                                                                                                                                                                                                                                                                  	| localhost 	|
| port                  	| Port where the server starts listening; 0 means a random port                                                                                                                                                                                                                                                                                                                                                                                                                         	| 0         	|
| offline               	| Include updates which were received while Telegram session was offline (applied only for first socket client)                                                                                                                                                                                                                                                                                                                                                                         	| false     	|
| tdlib                 	| Section of TDLib settings                                                                                                                                                                                                                                                                                                                                                                                                                                                             	|           	|
| tdlib/api_id          	| App api_id from [API development tools](https://my.telegram.org/apps)                                                                                                                                                                                                                                                                                                                                                                                                                 	|           	|
| tdlib/api_hash        	| App api_hash from [API development tools](https://my.telegram.org/apps)                                                                                                                                                                                                                                                                                                                                                                                                               	|           	|
| tdlib/path            	| Relative path where to save TDLib data. Make sure to match this value with the value from `docker-compose.yml` and follow to [update](#update) steps to apply changes.                                                                                                                                                                                                                                                                                                                	|           	|
| tdlib/debug_level     	| TDLib debug level:<br>0 - FATAL;<br>1 - ERROR;<br>2 - WARNING;<br>3 - INFO;<br>4 - DEBUG.                                                                                                                                                                                                                                                                                                                                                                                             	| 0         	|
| tdlib/proxy           	| Section of setting up connection to Telegram servers through proxy. Only one proxy server is supported at the moment.                                                                                                                                                                                                                                                                                                                                                                 	| (not set) 	|
| tdlib/proxy/type      	| Proxy type: `socks5`, `http` or `mtproto`                                                                                                                                                                                                                                                                                                                                                                                                                                             	|           	|
| tdlib/proxy/host      	| Host of proxy server                                                                                                                                                                                                                                                                                                                                                                                                                                                                  	|           	|
| tdlib/proxy/port      	| Port of proxy server                                                                                                                                                                                                                                                                                                                                                                                                                                                                  	|           	|
| tdlib/proxy/username  	| Username to authenticate on proxy server (for `socks5` and `http` types only; optional)                                                                                                                                                                                                                                                                                                                                                                                               	| (not set) 	|
| tdlib/proxy/password  	| Password to authenticate on proxy server (for `socks5` and `http` types only; optional)                                                                                                                                                                                                                                                                                                                                                                                               	| (not set) 	|
| tdlib/proxy/http_only 	| Pass `true`, if the proxy supports only HTTP requests and doesn't support transparent TCP connections via HTTP CONNECT method (for `http` type only)                                                                                                                                                                                                                                                                                                                                  	| false     	|
| tdlib/proxy/secret    	| The proxy's secret in hexadecimal encoding (for `mtproto` type only)                                                                                                                                                                                                                                                                                                                                                                                                                  	|           	|
| allowed_updates       	| List of allowed [update types](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1_update.html); [updateAuthorizationState](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_authorization_state.html) and [updateConnectionState](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_connection_state.html) are always allowed. See [below](#update-and-request-types-used-by-sip.tg-platform) for values which are used by SIP.tg platform. 	|           	|
| allowed_requests      	| List of allowed [RPC types](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1_function.html). See [below](#update-and-request-types-used-by-sip.tg-platform) for values which are used by SIP.tg platform.                                                                                                                                                                                                                                                                  	|           	|
| request_peers         	| Section which enumerates fields from [RPC types](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1_function.html) which have to preprocess to resolve `user_id` by the given username or phone number. Key represents the type of RPC request, value -- the field name which contains username or phone number (can be single value or a list of values).                                                                                                                   	|           	|
| format_fields         	| Section which enumerates fields to preprocess given text into [formattedText](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1formatted_text.html). Key represents the type name, value -- the field name which contains the text to preprocess.                                                                                                                                                                                                                           	|           	|
| format_markdown       	| Parse fields from `format_fields` as Markdown (if `true`) or as HTML (if `false`)                                                                                                                                                                                                                                                                                                                                                                                                     	| true      	|
| mysql                 	| Section of MySQL connection settings. If not set, data is saved locally only.                                                                                                                                                                                                                                                                                                                                                                                                         	| (not set) 	|
| mysql/host            	| Host of MySQL server                                                                                                                                                                                                                                                                                                                                                                                                                                                                  	|           	|
| mysql/port            	| Port of MySQL server                                                                                                                                                                                                                                                                                                                                                                                                                                                                  	| 3306      	|
| mysql/user            	| User name to authenticate by MySQL server                                                                                                                                                                                                                                                                                                                                                                                                                                             	|           	|
| mysql/password        	| Password to authenticate by MySQL server                                                                                                                                                                                                                                                                                                                                                                                                                                              	|           	|
| mysql/database        	| Name of the database to store the data                                                                                                                                                                                                                                                                                                                                                                                                                                                	|           	|
| mysql/charset         	| Default charset of string values                                                                                                                                                                                                                                                                                                                                                                                                                                                      	| utf8      	|
| mysql/read_timeout    	| Timeout before reconnect to MySQL server on read; 0 means system default                                                                                                                                                                                                                                                                                                                                                                                                              	| 0         	|
| mysql/debug           	| Debug output of MySQL communication                                                                                                                                                                                                                                                                                                                                                                                                                                                   	| false     	|
| mysql/ssl             	| Section of setting up a secure SSL connection to MySQL server                                                                                                                                                                                                                                                                                                                                                                                                                         	| (not set) 	|
| mysql/ssl/key         	| Relative path of SSL key file                                                                                                                                                                                                                                                                                                                                                                                                                                                         	|           	|
| mysql/ssl/cert        	| Relative path of SSL cert file                                                                                                                                                                                                                                                                                                                                                                                                                                                        	|           	|
| mysql/ssl/ca          	| Relative path of SSL ca file                                                                                                                                                                                                                                                                                                                                                                                                                                                          	|           	|

## Update and request types used by SIP.tg platform
Depending on the features you want to use, the list of allowed update and RPC request types can include one or multiple groups from the table:

| Feature                                                        | allowed_updates                                                                                                                                                                                                                                   | allowed_requests                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Managing the session from [@siptg_bot](https://t.me/siptg_bot) |                                                                                                                                                                                                                                                   | [setAuthenticationPhoneNumber](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_authentication_phone_number.html), [checkAuthenticationCode](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1check_authentication_code.html), [recoverAuthenticationPassword](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1recover_authentication_password.html), [requestAuthenticationPasswordRecovery](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1request_authentication_password_recovery.html), [getMe](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1get_me.html), [logOut](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1log_out.html) |
| Make voice calls (SIP→Telegram)                                | [updateCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_call.html), updateNewCallSignalingData                                                                                                                             | [getUser](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1get_user.html), [createCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1create_call.html), [discardCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1discard_call.html), [sendCallSignalingData](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1send_call_signaling_data.html), restoreCall                                                                                                                                                                                                                                                                                                    |
| Receive voice calls (Telegram→SIP)                             | [updateCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_call.html), updateNewCallSignalingData                                                                                                                             | receiveCall, [acceptCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1accept_call.html), [discardCall](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1discard_call.html), [sendCallSignalingData](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1send_call_signaling_data.html), restoreCall                                                                                                                                                                                                                                                                                                                                                                            |
| DTMF and Redial buttons                                        |                                                                                                                                                                                                                                                   | [getInlineQueryResults](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1get_inline_query_results.html), [sendInlineQueryResultMessage](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1send_inline_query_result_message.html), [deleteMessages](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1delete_messages.html)                                                                                                                                                                                                                                                                                                                                                         |
| Call to arbitrary numbers through PBX                          | [updateNewMessage](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_new_message.html)                                                                                                                                            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Managing the session of a White Label bot                      |                                                                                                                                                                                                                                                   | [checkAuthenticationBotToken](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1check_authentication_bot_token.html), [logOut](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1log_out.html)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Change settings via a White Label bot                          | [updateNewMessage](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_new_message.html), [updateNewCallbackQuery](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_new_callback_query.html)                       | [sendMessage](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1send_message.html), [editMessageText](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1edit_message_text.html), [editMessageReplyMarkup](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1edit_message_reply_markup.html)                                                                                                                                                                                                                                                                                                                                                                                         |
| Using a White Label bot for DTMF and Redial buttons            | [updateNewInlineQuery](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_new_inline_query.html), [updateNewInlineCallbackQuery](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1update_new_inline_callback_query.html) | [answerInlineQuery](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1answer_inline_query.html), [editInlineMessageText](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1edit_inline_message_text.html), [editInlineMessageReplyMarkup](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1edit_inline_message_reply_markup.html)                                                                                                                                                                                                                                                                                                                                                  |

## Storing data in external MySQL database
To store data externally, create new database on your MySQL server and apply `schema.sql` to create requried tables inside. After that change (or add if not exists) section `mysql` in `storage/settings.json` file according to the [instructions](#settings-file) and [restart](#restart) the storage.
