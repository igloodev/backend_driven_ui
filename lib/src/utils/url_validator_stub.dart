/// Web fallback for [isPrivateOrLoopbackIp] — `dart:io` (and its
/// `InternetAddress` IP parser) is unavailable on web.
///
/// Returns `false`: on web, private/loopback IP-literal detection falls back to
/// the pure-Dart IPv4-string check in `UrlValidator` (plus the localhost and
/// cloud-metadata string checks). Browsers also enforce CORS and sandboxing,
/// which substantially reduces the SSRF surface this guard targets.
bool isPrivateOrLoopbackIp(String host) => false;
