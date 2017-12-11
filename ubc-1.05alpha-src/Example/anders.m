export portal, portal_type

const _local <-0
const _remote <-1
const _querey <- 0
const _wait_for <- 1
const _specs_only <-0
const _loadfiles <-1

const portal_type <- typeobject portal_type
  operation aslookup ->[server_type]
  operation init[server_type]
end portal_type

const local_portal:portal_type <- object local_portal_obj
  var expo:server_type
  export operation aslookup ->[s:server_type]
    s<- expo
  end aslookup
  export operation init[s:server_type]
    expo<-s
  end init
end local_portal_obj


const portal <- immutable object portal
  export operation aslookup ->[s:server_type]
    s<-local_portal.aslookup
  end aslookup
end portal



%--------------------------------------------------------------------
%  TYPEOBJECTS
%----------------

const selektor_type <- typeobject to1
  operation setkey[string]
  operation getkey ->[string]
  operation setval[string]
  operation getval ->[string]
end to1

const querey_type <- typeobject to2
  operation setthe_agent[agent_type]
  operation getthe_agent ->[agent_type]
  operation setselector[array.of[selektor_type]]
  operation getselector ->[array.of[selektor_type]]
  operation copy[querey_type]
end to2

const doc_spec_type <- typeobject to3
  operation setid[string]
  operation getid ->[string]
  operation setsource_type[integer]
  operation getsource_type ->[integer]
  operation setlocal_source[string]
  operation getlocal_source ->[string]
  operation setremote_source[server_type]
  operation getremote_source ->[server_type]
  operation setdescription[string]
  operation getdescription ->[string]

  operation copy[doc_spec_type]
  operation match[selektor_type] -> [Boolean]
end to3

const agent_base_type <- typeobject to4
  operation respond[array.of[doc_spec_type]]
  operation s_init_call[server_type]
end to4

const agent_type <- typeobject to5
  operation setserver_ref[server_type]
  operation getserver_ref ->[server_type]
  operation sethome[agent_base_type]
  operation gethome ->[agent_base_type]
  operation settask[integer]
  operation gettask ->[integer]
  operation setquerey[querey_type]
  operation getquerey ->[querey_type]

  %operation wait_for_programming
  %operation mov[server_type]
  %operation ask
  %operation wait_for_q
  %operation wait_for_w
  %operation redirection[server_type]
  %operation return_home
  operation response[array.of[doc_spec_type]]
end to5

const server_type <- typeobject to6
  operation querey[querey_type]
  operation get_file[string]->[array.of[Character]]
  operation wait_for[querey_type]
  %operation respond[agent_type, array.of[doc_spec_type]]
  operation upload[doc_spec_type]
end to6
