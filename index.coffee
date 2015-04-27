request  = require 'request'
fs       = require 'fs'
_        = require 'underscore'
untangle = require './untangle'

settingsFile = "#{process.env.HOME}/.glesysnoderc"

loadDotFile = untangle () ->
  fs.readFile settingsFile, "utf8", @CONT (data) =>
    config = JSON.parse data
    settings = _.map config, (pass, user) -> { user: user, pass: pass }
    @RET settings


authForAccount = (account) ->
  {
    auth: {
      user: account.user,
      pass: account.pass,
      sendImmediatly: true
    }
  }

get = untangle (url, account) ->
  auth = authForAccount account
  request.get "https://api.glesys.com/#{url}/format/json", auth, @CONT (response, body) =>
    @RET JSON.parse(body)

post = untangle (url, params, account) ->
  options = authForAccount account
  options.form = params
  request.post "https://api.glesys.com/#{url}/format/json", options, @CONT (response, body) =>
    @RET JSON.parse(body)


gsGet = untangle (url, params, account) ->
  composedUrl = _.map(params, (val, key) -> "#{key}/#{val}").join('/')
  url = "#{url}/#{composedUrl}" if composedUrl != ""
  do (url, account) =>
    get url, account, @CONT (data) =>
      @RET(data.response)

gsPost = untangle (url, params, account) ->
  do (url, account) =>
    post url, params, account, @CONT (data) =>
      response = _.omit data.response, 'status', 'debug'
      keys = _.keys response
      @RET(response[keys[0]])


getter = (url, neededParams...) ->
  untangle (account, inParams) ->
    actualParams = {}
    actualParams = _.pick(inParams, neededParams...) if neededParams?
    gsGet url, actualParams, account, @PASS

poster = (url, neededParams...) ->
  parts = url.split '/'
  funcName = "gs" + parts.join('')
  url = url.toLowerCase()
  exports[funcName] = untangle (account, inParams) ->
    actualParams = {}
    actualParams = _.pick(inParams, neededParams...) if neededParams?
    gsPost url, actualParams, account, @PASS

# GETS
poster 'Server/List'

poster 'Server/Details'
  , 'serverid'
  , 'includestate' # optional

poster 'Server/Status'
  , 'serverid'
  , 'statustype' # optional

poster 'Server/Reboot'
  , 'serverid'

poster 'Server/Stop'
  , 'serverid'
  , 'type' # optional

poster 'Server/Start'
  , 'serverid'
  , 'bios' # optional

poster 'Server/Create'
  , 'datacenter'
  , 'platform'
  , 'hostname'
  , 'templatename'
  , 'disksize'
  , 'memorysize'
  , 'cpucores'
  , 'rootpassword'
  , 'transfer'
  , 'description' # optional
  , 'ip'          # optional
  , 'ipv6'        # optional

poster 'Server/Destroy'
  , 'serverid'
  , 'keepip'

poster 'Server/Edit'
  , 'serverid'
  , 'disksize'    # optional
  , 'memorysize'  # optional
  , 'cpucores'    # optional
  , 'transfer'    # optional
  , 'hostname'    # optional
  , 'description' # optional

poster 'Server/Clone'
  , 'serverid'
  , 'hostname'
  , 'disksize'    # optional
  , 'memorysize'  # optional
  , 'cpucores'    # optional
  , 'transfer'    # optional
  , 'description' # optional
  , 'datacenter'  # optional

poster 'Server/Limits'
  , 'serverid'

poster 'Server/Resetlimit'
  , 'serverid'
  , 'type'

poster 'Server/Console'
  , 'serverid'

poster 'Server/ResetPassword'
  , 'serverid'
  , 'rootpassword'

poster 'Server/Templates'

poster 'Server/AllowedArguments'
  , 'serverid' # optional

poster 'Server/ResourceUsage'
  , 'serverid'
  , 'resource'
  , 'resolution'

poster 'Server/Costs'
  , 'serverid'

poster 'Server/ListIso'
  , 'serverid'

poster 'Server/MountIso'
  , 'serverid'
  , 'isofile'

poster 'Server/AddIso'
  , 'archiveusername'
  , 'archivepassword'
  , 'archivepath'

poster 'Ip/ListFree'
  , 'ipversion'
  , 'datacenter'
  , 'platform'

poster 'Ip/ListOwn'
  , 'used'        # optional
  , 'serverid'    # optional
  , 'ipversion'   # optional
  , 'datacenter'  # optional
  , 'platform'    # optional

poster 'Ip/Details'
  , 'ipaddress'

poster 'Ip/Take'
  , 'ipaddress'

poster 'Ip/Release'
  , 'ipaddress'

poster 'Ip/Add'
  , 'serverid'
  , 'ipaddress'

poster 'Ip/Remove'
  , 'ipaddress'

poster 'Ip/SetPtr'
  , 'ipaddress'
  , 'data'

poster 'Ip/ResetPtr'
  , 'ipaddress'

poster 'Domain/List'

poster 'Domain/Add'
  , 'domainname'
  , 'primarynameserver' # Optional
  , 'responsibleperson' # Optional
  , 'ttl' # Optional
  , 'refresh' # Optional
  , 'retry' # Optional
  , 'expire' # Optional
  , 'minimum' # Optional
  , 'createrecords' # Optional

poster 'Domain/Register'
  , 'domainname'
  , 'email'
  , 'firstname'
  , 'lastname'
  , 'organization'
  , 'organizationnumber'
  , 'address'
  , 'city'
  , 'zipcode'
  , 'country'
  , 'phonenumber'
  , 'fax'       # Optional
  , 'numyears'  # Optional

poster 'Domain/Transfer'
  , 'domainname'
  , 'authcode'
  , 'email'
  , 'firstname'
  , 'lastname'
  , 'organization'
  , 'organizationnumber'
  , 'address'
  , 'city'
  , 'zipcode'
  , 'country'
  , 'phonenumber'
  , 'fax'       # Optional
  , 'numyears'  # Optional

poster 'Domain/Renew'
  , 'domainname'
  , 'numyears'

poster 'Domain/SetAutoRenew'
  , 'domainname'
  , 'autorenew'

poster 'Domain/Detail'
  , 'domainname'

poster 'Domain/Available'
  , 'search'

poster 'Domain/Pricelist'

poster 'Domain/Edit'
  , 'domainname'
  , 'primarynameserver'
  , 'responsibleperson'
  , 'ttl'
  , 'refresh'
  , 'retry'
  , 'expire'
  , 'minimum'

poster 'Domain/Delete'
  , 'domainname'

poster 'Domain/UpdateRecord'
  , 'recordid'
  , 'ttl'
  , 'host'
  , 'type'
  , 'data'

poster 'Domain/ListRecords'
  , 'domainname'

poster 'Domain/AddRecord'
  , 'domainname'
  , 'host'
  , 'type'
  , 'data'
  , 'ttl' # Optional

poster 'Domain/DeleteRecord'
  , 'recordid'

poster 'Domain/AllowedArguments'

poster 'Domain/ChangeNameServers'
  , 'domainname'
  , 'ns1'
  , 'ns2'
  , 'ns3' # Optional
  , 'ns4' # Optional

#gsDomainEdit      = getter 'domain', 'domain/edit'
  #, 'domainname'
  #, 'primarynameserver'
  #, 'responsibleperson'
  #, 'ttl'
  #, 'refresh'
  #, 'retry'
  #, 'expire'
  #, 'minimum'

# POST
#gsServerReboot  = poster 'server', 'server/reboot', 'serverid'
#gsServerStop    = poster ''

formatListServers = (list) ->
  iterator = (memo, server) ->
    "#{memo}#{server.serverid} #{server.hostname}\n"
  _.reduce data.response.servers, iterator, ""

loadDotFile (err, settings) ->
  if err?
    console.error "Could not load #{settingsFile}"
    console.error err
  else
    exports.gsServerList settings[0], (err, servers) ->
      console.dir servers
      exports.gsServerDetails settings[0], servers[0], (err, details) ->
        console.dir details
        console.log "Done"

