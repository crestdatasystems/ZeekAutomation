## This file is added into /usr/local/zeek/share/zeek/site path
## Used to add new attributes "vpc_name" and "project_id" in all required logs

# redef Config::config_flies += { "/usr/local/zeek/share/zeek/site/vpc_config.dat" };

redef record Conn::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

redef record HTTP::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

redef record SSL::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

redef record SSH::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

redef record DNS::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

redef record DHCP::Info += {
        vpc_name: string &default="vpc" &log;
        project_id: string &default="project" &log;
};

event connection_state_remove(c: connection) &priority=5
        {
        c$conn$vpc_name = VpcModule::vpc_name;
        c$conn$project_id = VpcModule::project_id;
        }

event dns_end(c: connection, msg: dns_msg)
        {
        c$dns$vpc_name = VpcModule::vpc_name;
        c$dns$project_id = VpcModule::project_id;
        }

event ssl_established(c: connection) &priority=5
        {
        c$ssl$vpc_name = VpcModule::vpc_name;
        c$ssl$project_id = VpcModule::project_id;
        }

event ssh_auth_attempted(c: connection, authenticated: bool) &priority=5
        {
        c$ssh$vpc_name = VpcModule::vpc_name;
        c$ssh$project_id = VpcModule::project_id;
        }

event http_message_done(c: connection, is_orig: bool, stat: http_message_stat) &priority = 5
        {
        c$http$vpc_name = VpcModule::vpc_name;
        c$http$project_id = VpcModule::project_id;
        }

event dhcp_message(c: connection, is_orig: bool, msg: DHCP::Msg, options: DHCP::Options) &priority=5
        {
        c$dhcp$vpc_name = VpcModule::vpc_name;
        c$dhcp$project_id = VpcModule::project_id;
        }