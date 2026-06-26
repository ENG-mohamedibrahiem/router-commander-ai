/// ZTE router protocol constants.
///
/// Every constant is annotated with its classification and evidence source.
/// Do NOT add a constant here unless you can state its classification.
///
/// Conventions:
///   // classification: VERIFIED — <evidence>
///   // classification: ASSUMED  — <rationale + fallback>
///   // classification: EXPERIMENTAL — <why + guard required>
library zte_protocol_constants;

/// The single HTTP endpoint for ALL read operations on ZTE routers.
///
/// classification: VERIFIED — confirmed across MF79U, MF266, MF297D, MC801A
/// from firmware JS deobfuscation and community packet captures.
const String kZteGetCmdEndpoint = '/goform/goform_get_cmd_process';

/// The HTTP endpoint for ALL write/action operations on ZTE routers.
///
/// classification: VERIFIED — confirmed across MF79U, MF266, MF297D, MC801A.
const String kZteSetCmdEndpoint = '/goform/goform_set_cmd_process';

/// The query parameter name for the field list in a read request.
///
/// classification: VERIFIED — confirmed from firmware JS source.
const String kZteMultiParam = 'multi_data';

/// The value of [kZteMultiParam] when requesting multiple fields.
///
/// classification: VERIFIED — confirmed from firmware JS source.
const String kZteMultiParamValue = '1';

/// Field name for the SHA-256 capability flag.
///
/// The firmware returns a string value:
///   '2' → SHA-256 chained  sha256(sha256(password) + LD)
///   '1' → SHA-256 simple   sha256(base64(password))
///   '0' → Base-64 only     base64(password)  — legacy models e.g. MF253M
///
/// classification: VERIFIED — confirmed from MF297D firmware JS deobfuscation.
const String kZteAuthCapabilityField = 'WEB_ATTR_IF_SUPPORT_SHA256';

/// Field name for the LD anti-replay token used in SHA-256 chained auth.
///
/// classification: VERIFIED — confirmed from MF297D firmware JS.
const String kZteLdTokenField = 'LD';

/// The field returned in the login response body.
///
/// classification: VERIFIED — value is always the string 'sucess' (sic —
/// the firmware contains a known typo). Both spellings are accepted
/// by ZteAuthenticationStrategy for defensive parsing.
const String kZteLoginResultField = 'result';

/// The CORRECT (typo-inclusive) success value from the firmware.
///
/// classification: VERIFIED — firmware typo confirmed across multiple models.
const String kZteLoginSuccessValue = 'sucess';

/// Alternate success spelling accepted defensively.
///
/// classification: ASSUMED — no model observed returning this, but accepted
/// to guard against future firmware corrections.
/// fallback: if observed, log via ProtocolLogger.logFallback and accept.
const String kZteLoginSuccessValueAlt = 'success';

/// Session cookie name used by modern ZTE models (MF79U, MF266).
///
/// classification: VERIFIED — observed in Set-Cookie headers on listed models.
const String kZteSessionCookieStok = 'stok';

/// Session cookie name used by MF297D and related models.
///
/// classification: VERIFIED — observed in Set-Cookie headers on MF297D.
const String kZteSessionCookieZsidn = 'zsidn';

/// Referer header value suffix required on every ZTE HTTP request.
///
/// classification: VERIFIED — requests without Referer are rejected by
/// the router's built-in HTTP server on all confirmed models.
const String kZteRefererSuffix = '/';

/// HTTP connect + receive timeout for ZTE requests.
///
/// classification: ASSUMED — ZTE routers are on local LAN; 10s is generous.
/// fallback: configurable via ZteAdapterConfig; this is the default only.
const Duration kZteDefaultTimeout = Duration(seconds: 10);

/// Field name for the AD anti-replay write token (modern firmware).
///
/// classification: VERIFIED — confirmed on MF297D and MC801A.
/// Note: ONLY required for write operations. Reads do not need AD.
const String kZteAdTokenField = 'AD';

/// The empty-string sentinel value ZTE returns for unavailable fields.
///
/// classification: VERIFIED — confirmed across all read responses.
/// Any field equal to this value must be mapped to null in domain entities.
const String kZteUnavailableValue = '';
