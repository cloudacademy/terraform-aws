describe package('nginx') do
    it { should be_installed }
end

# # frozen_string_literal: true

# # Copyright:: 2015, Patrick Muench
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
# #
# # author: Christoph Hartmann
# # author: Dominik Richter
# # author: Patrick Muench

# title 'NGINX server config'

# # attributes
# CLIENT_MAX_BODY_SIZE = input(
#   'client_max_body_size',
#   description: 'Sets the maximum allowed size of the client request body, specified in the “Content-Length” request header field. If the size in a request exceeds the configured value, the 413 (Request Entity Too Large) error is returned to the client. Please be aware that browsers cannot correctly display this error. Setting size to 0 disables checking of client request body size.',
#   value: '1k'
# )

# CLIENT_BODY_BUFFER_SIZE = input(
#   'client_body_buffer_size',
#   description: 'Sets buffer size for reading client request body. In case the request body is larger than the buffer, the whole body or only its part is written to a temporary file. By default, buffer size is equal to two memory pages. This is 8K on x86, other 32-bit platforms, and x86-64. It is usually 16K on other 64-bit platforms.',
#   value: '1k'
# )

# CLIENT_HEADER_BUFFER_SIZE = input(
#   'client_header_buffer_size',
#   description: 'Sets buffer size for reading client request header. For most requests, a buffer of 1K bytes is enough. However, if a request includes long cookies, or comes from a WAP client, it may not fit into 1K. If a request line or a request header field does not fit into this buffer then larger buffers, configured by the large_client_header_buffers directive, are allocated.',
#   value: '1k'
# )

# LARGE_CLIENT_HEADER_BUFFER = input(
#   'large_client_header_buffers',
#   description: 'Sets the maximum number and size of buffers used for reading large client request header. A request line cannot exceed the size of one buffer, or the 414 (Request-URI Too Large) error is returned to the client. A request header field cannot exceed the size of one buffer as well, or the 400 (Bad Request) error is returned to the client. Buffers are allocated only on demand. By default, the buffer size is equal to 8K bytes. If after the end of request processing a connection is transitioned into the keep-alive state, these buffers are released.',
#   value: '2 1k'
# )

# KEEPALIVE_TIMEOUT = input(
#   'keepalive_timeout',
#   description: 'The first parameter sets a timeout during which a keep-alive client connection will stay open on the server side. The zero value disables keep-alive client connections. The optional second parameter sets a value in the “Keep-Alive: timeout=time” response header field. Two parameters may differ.',
#   value: '5 5'
# )

# CLIENT_BODY_TIMEOUT = input(
#   'client_body_timeout',
#   description: 'Defines a timeout for reading client request body. The timeout is set only for a period between two successive read operations, not for the transmission of the whole request body. If a client does not transmit anything within this time, the 408 (Request Time-out) error is returned to the client.',
#   value: '10'
# )

# CLIENT_HEADER_TIMEOUT = input(
#   'client_header_timeout',
#   description: 'Defines a timeout for reading client request header. If a client does not transmit the entire header within this time, the 408 (Request Time-out) error is returned to the client.',
#   value: '10'
# )

# SEND_TIMEOUT = input(
#   'send_timeout',
#   description: 'Sets a timeout for transmitting a response to the client. The timeout is set only between two successive write operations, not for the transmission of the whole response. If the client does not receive anything within this time, the connection is closed.',
#   value: '10'
# )

# HTTP_METHODS = input(
#   'http_methods',
#   description: 'Specify the used HTTP methods',
#   value: 'GET\|HEAD\|POST'
# )

# HTTP_METHODS_CHECK = input(
#   'http_methods_check',
#   description: 'Defines if http_methods should be checked in the nginx configuration',
#   value: false
# )

# NGINX_COOKIE_FLAG_MODULE = input(
#   'nginx_cookie_flag_module',
#   description: 'Defines if nginx has been compiled with nginx_cookie_flag_module',
#   value: false
# )

# only_if do
#   command('nginx').exist?
# end

# # determine all required paths
# nginx_path          = input('nginx_path', value: '/etc/nginx', description: 'Default nginx configurations path')
# nginx_conf          = File.join(nginx_path, 'nginx.conf')
# nginx_confd         = File.join(nginx_path, 'conf.d')
# nginx_enabled       = File.join(nginx_path, 'sites-enabled')
# nginx_parsed_config = command('nginx -T').stdout

# options = {
#   assignment_regex: /^\s*([^:]*?)\s*\ \s*(.*?)\s*;$/,
# }

# options_add_header = {
#   assignment_regex: /^\s*([^:]*?)\s*\ \s*(.*?)\s*;$/,
#   multiple_values: true,
# }

# control 'nginx-01' do
#   impact 1.0
#   title 'Running worker process as non-privileged user'
#   desc 'The NGINX worker processes should run as non-privileged user. In case of compromise of the process, an attacker has full access to the system.'
#   describe user(nginx_lib.valid_users) do
#     it { should exist }
#   end
#   describe parse_config_file(nginx_conf, options) do
#     its('user') { should eq nginx_lib.valid_users }
#   end

#   describe parse_config_file(nginx_conf, options) do
#     its('group') { should_not eq 'root' }
#   end
# end

# control 'nginx-02' do
#   impact 1.0
#   title 'Check NGINX config file owner, group and permissions.'
#   desc 'The NGINX config file should owned by root, only be writable by owner and not write- and readable by others.'
#   describe file(nginx_conf) do
#     it { should be_owned_by 'root' }
#     it { should be_grouped_into 'root' }
#     it { should_not be_readable.by('others') }
#     it { should_not be_writable.by('others') }
#     it { should_not be_executable.by('others') }
#   end
# end

# control 'nginx-03' do
#   impact 1.0
#   title 'Nginx default files'
#   desc 'Remove the default nginx config files.'
#   describe file(File.join(nginx_confd, 'default.conf')) do
#     it { should_not be_file }
#   end

#   describe file(File.join(nginx_enabled, 'default')) do
#     it { should_not be_file }
#   end
# end

# control 'nginx-04' do
#   impact 1.0
#   title 'Check for multiple instances'
#   desc 'Different instances of the nginx webserver should run in separate environments'
#   describe command('ps aux | egrep "nginx: master" | egrep -v "grep" | wc -l') do
#     its(:stdout) { should match(/^1$/) }
#   end
# end

# control 'nginx-05' do
#   impact 1.0
#   title 'Disable server_tokens directive'
#   desc 'Disables emitting nginx version in error messages and in the “Server” response header field.'
#   describe parse_config(nginx_parsed_config, options) do
#     its('server_tokens') { should eq 'off' }
#   end
# end

# control 'nginx-06' do
#   impact 1.0
#   title 'Prevent buffer overflow attacks'
#   desc 'Buffer overflow attacks are made possible by writing data to a buffer and exceeding that buffer boundary and overwriting memory fragments of a process. To prevent this in nginx we can set buffer size limitations for all clients.'
#   describe parse_config(nginx_parsed_config, options) do
#     its('client_body_buffer_size') { should eq CLIENT_BODY_BUFFER_SIZE }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('client_max_body_size') { should eq CLIENT_MAX_BODY_SIZE }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('client_header_buffer_size') { should eq CLIENT_HEADER_BUFFER_SIZE }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('large_client_header_buffers') { should eq LARGE_CLIENT_HEADER_BUFFER }
#   end
# end

# control 'nginx-07' do
#   impact 1.0
#   title 'Control simultaneous connections'
#   desc 'NginxHttpLimitZone module to limit the number of simultaneous connections for the assigned session or as a special case, from one IP address.'
#   describe parse_config(nginx_parsed_config, options) do
#     its('limit_conn_zone') { should eq '$binary_remote_addr zone=default:10m' }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('limit_conn') { should eq 'default 5' }
#   end
# end

# control 'nginx-08' do
#   impact 1.0
#   title 'Prevent clickjacking'
#   desc 'Do not allow the browser to render the page inside an frame or iframe.'
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('add_header') { should include 'X-Frame-Options SAMEORIGIN' }
#   end
# end

# control 'nginx-09' do
#   impact 1.0
#   title 'Enable Cross-site scripting filter'
#   desc 'This header is used to configure the built in reflective XSS protection. This tells the browser to block the response if it detects an attack rather than sanitising the script.'
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('add_header') { should include 'X-XSS-Protection "1; mode=block"' }
#   end
# end

# control 'nginx-10' do
#   impact 1.0
#   title 'Disable content-type sniffing'
#   desc 'It prevents browser from trying to mime-sniff the content-type of a response away from the one being declared by the server. It reduces exposure to drive-by downloads and the risks of user uploaded content that, with clever naming, could be treated as a different content-type, like an executable.'
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('add_header') { should include 'X-Content-Type-Options nosniff' }
#   end
# end

# control 'nginx-12' do
#   impact 1.0
#   title 'TLS Protocols'
#   desc 'When choosing a cipher during an SSLv3 or TLSv1 handshake, normally the client\'s preference is used. If this directive is enabled, the server\'s preference will be used instead.'
#   ref 'SSL Hardening config', url: 'https://mozilla.github.io/server-side-tls/ssl-config-generator/'
#   describe parse_config(nginx_parsed_config, options) do
#     its('ssl_protocols') { should be_in ['TLSv1.3', 'TLSv1.2', 'TLSv1.2 TLSv1.3', 'TLSv1.3 TLSv1.2'] }
#     its('ssl_session_tickets') { should eq 'off' }
#     its('ssl_ciphers') { should eq '\'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256\'' }
#     its('ssl_prefer_server_ciphers') { should eq 'on' }
#     its('ssl_dhparam') { should eq '/etc/nginx/dh4096.pem' }
#   end
# end

# control 'nginx-13' do
#   impact 1.0
#   title 'Add HSTS Header'
#   desc 'HTTP Strict Transport Security (HSTS) is a web security policy mechanism which helps to protect websites against protocol downgrade attacks and cookie hijacking. It allows web servers to declare that web browsers (or other complying user agents) should only interact with it using secure HTTPS connections, and never via the insecure HTTP protocol. HSTS is an IETF standards track protocol and is specified in RFC 6797.'
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('add_header') { should include 'Strict-Transport-Security max-age=15768000' }
#   end
# end

# control 'nginx-14' do
#   impact 1.0
#   title 'Disable insecure HTTP-methods'
#   desc 'Disable insecure HTTP-methods and allow only necessary methods.'
#   ref 'OWASP HTTP Methods', url: 'https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)'

#   only_if { HTTP_METHODS_CHECK != false }
#   describe file(nginx_conf) do
#     its('content') { should match(/^\s*if\s+\(\$request_method\s+!~\s+\^\(#{HTTP_METHODS}\)\$\)\{?$/) }
#   end
# end

# control 'nginx-15' do
#   impact 1.0
#   title 'Content-Security-Policy'
#   desc 'The Content-Security-Policy HTTP response header helps you reduce XSS risks on modern browsers by declaring what dynamic resources are allowed to load via a HTTP Header'
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('add_header') { should include 'Content-Security-Policy "script-src \'self\'; object-src \'self\'"' }
#   end
# end

# control 'nginx-16' do
#   impact 1.0
#   title 'Set cookie with HttpOnly and Secure flag'
#   desc 'You can mitigate most of the common Cross Site Scripting attack using HttpOnly and Secure flag in a cookie. Without having HttpOnly and Secure, it is possible to steal or manipulate web application session and cookies and it’s dangerous.'
#   only_if { NGINX_COOKIE_FLAG_MODULE != false }
#   describe parse_config(nginx_parsed_config, options_add_header) do
#     its('set_cookie_flag') { should include '* HttpOnly secure' }
#   end
# end

# control 'nginx-17' do
#   impact 1.0
#   title 'Control timeouts to improve performance'
#   desc 'Control timeouts to improve server performance and cut clients.'
#   describe parse_config(nginx_parsed_config, options) do
#     its('keepalive_timeout') { should eq KEEPALIVE_TIMEOUT }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('client_body_timeout') { should eq CLIENT_BODY_TIMEOUT }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('client_header_timeout') { should eq CLIENT_HEADER_TIMEOUT }
#   end
#   describe parse_config(nginx_parsed_config, options) do
#     its('send_timeout') { should eq SEND_TIMEOUT }
#   end
# end