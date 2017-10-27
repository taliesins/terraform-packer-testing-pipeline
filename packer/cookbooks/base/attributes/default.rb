default[:base][:essential_packages] = [ 'unzip',
                                        'tree',
                                        'jq',
                                        'curl' ]
default[:base][:goss][:file_location] = "/usr/local/bin/goss"
default[:base][:goss][:version] = '0.3.5'
default[:base][:goss][:file_uri] = "https://github.com/aelsabbahy/goss/releases/download/v#{default[:base][:goss][:version]}/goss-linux-amd64"
