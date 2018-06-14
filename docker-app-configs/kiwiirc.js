function read_env(name, default_value) {
    if (typeof process.env[name] != 'undefined') {
        return process.env[name];
    }
    return default_value;
}

var conf = {
    // user: '',
    // group: '',
    log: "kiwi.log",
    servers: [],
    outgoing_address: {
        IPv4: '0.0.0.0'
        //IPv6: '::'
    },
    identd: {
        enabled: false,
        port: 113,
        address: "0.0.0.0"
    },
    public_http: "client/",
    /* client_transports: [
     'polling'
     ], */
    max_client_conns: 5,
    max_server_conns: 0,
    default_encoding: 'utf8',
    default_gecos: '%n is using a Web IRC client',
    default_ident: '%i',
    quit_message: '',
    ircd_reconnect: true,
    client_plugins: [],
    module_dir: "../server_modules/",
    modules: [],
    webirc_pass: '',
    reject_unauthorised_certificates: false,
    http_proxies: ["127.0.0.1/32"],
    http_proxy_ip_header: "x-forwarded-for",
    http_base_path: "/kiwi",
    socks_proxy: {
        enabled: false,
        all: false,
        proxy_hosts: [

        ],
        address: '127.0.0.1',
        port: 1080,
        user: null,
        pass: null
    },
    client: {
        server: read_env('KIWI_SERVER_IP', '127.0.0.1'),
        port:   read_env('KIWI_SERVER_PORT', 6667),
        ssl:    read_env('KIWI_SERVER_SSL', false),
        channel: read_env('KIWI_JOIN_CHANNEL', '#seabattle'),
        channel_key: '',
        nick:    read_env('KIWI_NICK', 'kiwi_?'),
        settings: {
            theme: 'relaxed',
            text_theme: 'default',
            channel_list_style: 'tabs',
            scrollback: 250,
            show_joins_parts: true,
            show_timestamps: false,
            use_24_hour_timestamps: true,
            mute_sounds: false,
            show_emoticons: true,
            ignore_new_queries: false,
            count_all_activity: false,
            show_autocomplete_slideout: true,
            locale: null // null = use the browser locale settings
        },
        window_title: read_env('KIWI_TITLE', 'Kiwi IRC')
    },
    client_themes: [
        'relaxed',
        'mini',
        'cli',
        'basic'
    ]
};

conf.servers.push({
    port:   read_env('KIWI_PORT', 7778),
    address: read_env('KIWI_BIND', "0.0.0.0")
});

/*
 * Do not amend the below lines unless you understand the changes!
 */
module.exports.production = conf;
