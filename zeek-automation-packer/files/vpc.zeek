module VpcModule;

redef Config::config_files += {"/usr/local/zeek/share/zeek/site/vpc_config.dat"};

export {
        option vpc_name = "xyz";
        option project_id = "abc";
}