// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RsServerEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RsServerEvent()';
}


}

/// @nodoc
class $RsServerEventCopyWith<$Res>  {
$RsServerEventCopyWith(RsServerEvent _, $Res Function(RsServerEvent) __);
}


/// Adds pattern-matching-related methods to [RsServerEvent].
extension RsServerEventPatterns on RsServerEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RsServerEvent_Register value)?  register,TResult Function( RsServerEvent_PrepareUpload value)?  prepareUpload,TResult Function( RsServerEvent_FileUpload value)?  fileUpload,TResult Function( RsServerEvent_SessionEnd value)?  sessionEnd,TResult Function( RsServerEvent_PrepareUploadAborted value)?  prepareUploadAborted,TResult Function( RsServerEvent_CancelReceived value)?  cancelReceived,TResult Function( RsServerEvent_WebPrepareDownload value)?  webPrepareDownload,TResult Function( RsServerEvent_WebFileDownload value)?  webFileDownload,TResult Function( RsServerEvent_StreamPrepareSession value)?  streamPrepareSession,TResult Function( RsServerEvent_StreamFileRequest value)?  streamFileRequest,TResult Function( RsServerEvent_Show value)?  show_,TResult Function( RsServerEvent_HomeHubInviteRequest value)?  homeHubInviteRequest,TResult Function( RsServerEvent_HomeHubChatMessage value)?  homeHubChatMessage,TResult Function( RsServerEvent_HomeHubTransferOffer value)?  homeHubTransferOffer,TResult Function( RsServerEvent_ListenerFailed value)?  listenerFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RsServerEvent_Register() when register != null:
return register(_that);case RsServerEvent_PrepareUpload() when prepareUpload != null:
return prepareUpload(_that);case RsServerEvent_FileUpload() when fileUpload != null:
return fileUpload(_that);case RsServerEvent_SessionEnd() when sessionEnd != null:
return sessionEnd(_that);case RsServerEvent_PrepareUploadAborted() when prepareUploadAborted != null:
return prepareUploadAborted(_that);case RsServerEvent_CancelReceived() when cancelReceived != null:
return cancelReceived(_that);case RsServerEvent_WebPrepareDownload() when webPrepareDownload != null:
return webPrepareDownload(_that);case RsServerEvent_WebFileDownload() when webFileDownload != null:
return webFileDownload(_that);case RsServerEvent_StreamPrepareSession() when streamPrepareSession != null:
return streamPrepareSession(_that);case RsServerEvent_StreamFileRequest() when streamFileRequest != null:
return streamFileRequest(_that);case RsServerEvent_Show() when show_ != null:
return show_(_that);case RsServerEvent_HomeHubInviteRequest() when homeHubInviteRequest != null:
return homeHubInviteRequest(_that);case RsServerEvent_HomeHubChatMessage() when homeHubChatMessage != null:
return homeHubChatMessage(_that);case RsServerEvent_HomeHubTransferOffer() when homeHubTransferOffer != null:
return homeHubTransferOffer(_that);case RsServerEvent_ListenerFailed() when listenerFailed != null:
return listenerFailed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RsServerEvent_Register value)  register,required TResult Function( RsServerEvent_PrepareUpload value)  prepareUpload,required TResult Function( RsServerEvent_FileUpload value)  fileUpload,required TResult Function( RsServerEvent_SessionEnd value)  sessionEnd,required TResult Function( RsServerEvent_PrepareUploadAborted value)  prepareUploadAborted,required TResult Function( RsServerEvent_CancelReceived value)  cancelReceived,required TResult Function( RsServerEvent_WebPrepareDownload value)  webPrepareDownload,required TResult Function( RsServerEvent_WebFileDownload value)  webFileDownload,required TResult Function( RsServerEvent_StreamPrepareSession value)  streamPrepareSession,required TResult Function( RsServerEvent_StreamFileRequest value)  streamFileRequest,required TResult Function( RsServerEvent_Show value)  show_,required TResult Function( RsServerEvent_HomeHubInviteRequest value)  homeHubInviteRequest,required TResult Function( RsServerEvent_HomeHubChatMessage value)  homeHubChatMessage,required TResult Function( RsServerEvent_HomeHubTransferOffer value)  homeHubTransferOffer,required TResult Function( RsServerEvent_ListenerFailed value)  listenerFailed,}){
final _that = this;
switch (_that) {
case RsServerEvent_Register():
return register(_that);case RsServerEvent_PrepareUpload():
return prepareUpload(_that);case RsServerEvent_FileUpload():
return fileUpload(_that);case RsServerEvent_SessionEnd():
return sessionEnd(_that);case RsServerEvent_PrepareUploadAborted():
return prepareUploadAborted(_that);case RsServerEvent_CancelReceived():
return cancelReceived(_that);case RsServerEvent_WebPrepareDownload():
return webPrepareDownload(_that);case RsServerEvent_WebFileDownload():
return webFileDownload(_that);case RsServerEvent_StreamPrepareSession():
return streamPrepareSession(_that);case RsServerEvent_StreamFileRequest():
return streamFileRequest(_that);case RsServerEvent_Show():
return show_(_that);case RsServerEvent_HomeHubInviteRequest():
return homeHubInviteRequest(_that);case RsServerEvent_HomeHubChatMessage():
return homeHubChatMessage(_that);case RsServerEvent_HomeHubTransferOffer():
return homeHubTransferOffer(_that);case RsServerEvent_ListenerFailed():
return listenerFailed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RsServerEvent_Register value)?  register,TResult? Function( RsServerEvent_PrepareUpload value)?  prepareUpload,TResult? Function( RsServerEvent_FileUpload value)?  fileUpload,TResult? Function( RsServerEvent_SessionEnd value)?  sessionEnd,TResult? Function( RsServerEvent_PrepareUploadAborted value)?  prepareUploadAborted,TResult? Function( RsServerEvent_CancelReceived value)?  cancelReceived,TResult? Function( RsServerEvent_WebPrepareDownload value)?  webPrepareDownload,TResult? Function( RsServerEvent_WebFileDownload value)?  webFileDownload,TResult? Function( RsServerEvent_StreamPrepareSession value)?  streamPrepareSession,TResult? Function( RsServerEvent_StreamFileRequest value)?  streamFileRequest,TResult? Function( RsServerEvent_Show value)?  show_,TResult? Function( RsServerEvent_HomeHubInviteRequest value)?  homeHubInviteRequest,TResult? Function( RsServerEvent_HomeHubChatMessage value)?  homeHubChatMessage,TResult? Function( RsServerEvent_HomeHubTransferOffer value)?  homeHubTransferOffer,TResult? Function( RsServerEvent_ListenerFailed value)?  listenerFailed,}){
final _that = this;
switch (_that) {
case RsServerEvent_Register() when register != null:
return register(_that);case RsServerEvent_PrepareUpload() when prepareUpload != null:
return prepareUpload(_that);case RsServerEvent_FileUpload() when fileUpload != null:
return fileUpload(_that);case RsServerEvent_SessionEnd() when sessionEnd != null:
return sessionEnd(_that);case RsServerEvent_PrepareUploadAborted() when prepareUploadAborted != null:
return prepareUploadAborted(_that);case RsServerEvent_CancelReceived() when cancelReceived != null:
return cancelReceived(_that);case RsServerEvent_WebPrepareDownload() when webPrepareDownload != null:
return webPrepareDownload(_that);case RsServerEvent_WebFileDownload() when webFileDownload != null:
return webFileDownload(_that);case RsServerEvent_StreamPrepareSession() when streamPrepareSession != null:
return streamPrepareSession(_that);case RsServerEvent_StreamFileRequest() when streamFileRequest != null:
return streamFileRequest(_that);case RsServerEvent_Show() when show_ != null:
return show_(_that);case RsServerEvent_HomeHubInviteRequest() when homeHubInviteRequest != null:
return homeHubInviteRequest(_that);case RsServerEvent_HomeHubChatMessage() when homeHubChatMessage != null:
return homeHubChatMessage(_that);case RsServerEvent_HomeHubTransferOffer() when homeHubTransferOffer != null:
return homeHubTransferOffer(_that);case RsServerEvent_ListenerFailed() when listenerFailed != null:
return listenerFailed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String ip,  RegisterDtoV2 info)?  register,TResult Function( String sessionId,  String ip,  RegisterDtoV2 info,  String? certFingerprint,  Map<String, FileDto> files)?  prepareUpload,TResult Function( String sessionId,  String fileId,  FileDto file)?  fileUpload,TResult Function( String sessionId,  SessionEndReasonV2 reason)?  sessionEnd,TResult Function( String sessionId)?  prepareUploadAborted,TResult Function( String ip,  String sessionId)?  cancelReceived,TResult Function( String ip,  String sessionId,  String? userAgent)?  webPrepareDownload,TResult Function( String sessionId,  String fileId,  FileDto file)?  webFileDownload,TResult Function( String ip,  String sessionId,  String? userAgent)?  streamPrepareSession,TResult Function( String ip,  String sessionId,  String requestId,  RsStreamEntry entry,  String purpose)?  streamFileRequest,TResult Function( List<String> args)?  show_,TResult Function( String ip,  String inviteId,  String groupId,  String groupName,  String senderDeviceId,  String senderAlias,  String role,  String createdAt,  String? expiresAt)?  homeHubInviteRequest,TResult Function( String eventId,  String groupId,  String senderDeviceId,  String senderAlias,  String text,  String createdAt)?  homeHubChatMessage,TResult Function( String ip,  String offerId,  String groupId,  String senderDeviceId,  String senderAlias,  List<RsHomeHubTransferFile> files)?  homeHubTransferOffer,TResult Function( String error)?  listenerFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RsServerEvent_Register() when register != null:
return register(_that.ip,_that.info);case RsServerEvent_PrepareUpload() when prepareUpload != null:
return prepareUpload(_that.sessionId,_that.ip,_that.info,_that.certFingerprint,_that.files);case RsServerEvent_FileUpload() when fileUpload != null:
return fileUpload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_SessionEnd() when sessionEnd != null:
return sessionEnd(_that.sessionId,_that.reason);case RsServerEvent_PrepareUploadAborted() when prepareUploadAborted != null:
return prepareUploadAborted(_that.sessionId);case RsServerEvent_CancelReceived() when cancelReceived != null:
return cancelReceived(_that.ip,_that.sessionId);case RsServerEvent_WebPrepareDownload() when webPrepareDownload != null:
return webPrepareDownload(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_WebFileDownload() when webFileDownload != null:
return webFileDownload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_StreamPrepareSession() when streamPrepareSession != null:
return streamPrepareSession(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_StreamFileRequest() when streamFileRequest != null:
return streamFileRequest(_that.ip,_that.sessionId,_that.requestId,_that.entry,_that.purpose);case RsServerEvent_Show() when show_ != null:
return show_(_that.args);case RsServerEvent_HomeHubInviteRequest() when homeHubInviteRequest != null:
return homeHubInviteRequest(_that.ip,_that.inviteId,_that.groupId,_that.groupName,_that.senderDeviceId,_that.senderAlias,_that.role,_that.createdAt,_that.expiresAt);case RsServerEvent_HomeHubChatMessage() when homeHubChatMessage != null:
return homeHubChatMessage(_that.eventId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.text,_that.createdAt);case RsServerEvent_HomeHubTransferOffer() when homeHubTransferOffer != null:
return homeHubTransferOffer(_that.ip,_that.offerId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.files);case RsServerEvent_ListenerFailed() when listenerFailed != null:
return listenerFailed(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String ip,  RegisterDtoV2 info)  register,required TResult Function( String sessionId,  String ip,  RegisterDtoV2 info,  String? certFingerprint,  Map<String, FileDto> files)  prepareUpload,required TResult Function( String sessionId,  String fileId,  FileDto file)  fileUpload,required TResult Function( String sessionId,  SessionEndReasonV2 reason)  sessionEnd,required TResult Function( String sessionId)  prepareUploadAborted,required TResult Function( String ip,  String sessionId)  cancelReceived,required TResult Function( String ip,  String sessionId,  String? userAgent)  webPrepareDownload,required TResult Function( String sessionId,  String fileId,  FileDto file)  webFileDownload,required TResult Function( String ip,  String sessionId,  String? userAgent)  streamPrepareSession,required TResult Function( String ip,  String sessionId,  String requestId,  RsStreamEntry entry,  String purpose)  streamFileRequest,required TResult Function( List<String> args)  show_,required TResult Function( String ip,  String inviteId,  String groupId,  String groupName,  String senderDeviceId,  String senderAlias,  String role,  String createdAt,  String? expiresAt)  homeHubInviteRequest,required TResult Function( String eventId,  String groupId,  String senderDeviceId,  String senderAlias,  String text,  String createdAt)  homeHubChatMessage,required TResult Function( String ip,  String offerId,  String groupId,  String senderDeviceId,  String senderAlias,  List<RsHomeHubTransferFile> files)  homeHubTransferOffer,required TResult Function( String error)  listenerFailed,}) {final _that = this;
switch (_that) {
case RsServerEvent_Register():
return register(_that.ip,_that.info);case RsServerEvent_PrepareUpload():
return prepareUpload(_that.sessionId,_that.ip,_that.info,_that.certFingerprint,_that.files);case RsServerEvent_FileUpload():
return fileUpload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_SessionEnd():
return sessionEnd(_that.sessionId,_that.reason);case RsServerEvent_PrepareUploadAborted():
return prepareUploadAborted(_that.sessionId);case RsServerEvent_CancelReceived():
return cancelReceived(_that.ip,_that.sessionId);case RsServerEvent_WebPrepareDownload():
return webPrepareDownload(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_WebFileDownload():
return webFileDownload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_StreamPrepareSession():
return streamPrepareSession(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_StreamFileRequest():
return streamFileRequest(_that.ip,_that.sessionId,_that.requestId,_that.entry,_that.purpose);case RsServerEvent_Show():
return show_(_that.args);case RsServerEvent_HomeHubInviteRequest():
return homeHubInviteRequest(_that.ip,_that.inviteId,_that.groupId,_that.groupName,_that.senderDeviceId,_that.senderAlias,_that.role,_that.createdAt,_that.expiresAt);case RsServerEvent_HomeHubChatMessage():
return homeHubChatMessage(_that.eventId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.text,_that.createdAt);case RsServerEvent_HomeHubTransferOffer():
return homeHubTransferOffer(_that.ip,_that.offerId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.files);case RsServerEvent_ListenerFailed():
return listenerFailed(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String ip,  RegisterDtoV2 info)?  register,TResult? Function( String sessionId,  String ip,  RegisterDtoV2 info,  String? certFingerprint,  Map<String, FileDto> files)?  prepareUpload,TResult? Function( String sessionId,  String fileId,  FileDto file)?  fileUpload,TResult? Function( String sessionId,  SessionEndReasonV2 reason)?  sessionEnd,TResult? Function( String sessionId)?  prepareUploadAborted,TResult? Function( String ip,  String sessionId)?  cancelReceived,TResult? Function( String ip,  String sessionId,  String? userAgent)?  webPrepareDownload,TResult? Function( String sessionId,  String fileId,  FileDto file)?  webFileDownload,TResult? Function( String ip,  String sessionId,  String? userAgent)?  streamPrepareSession,TResult? Function( String ip,  String sessionId,  String requestId,  RsStreamEntry entry,  String purpose)?  streamFileRequest,TResult? Function( List<String> args)?  show_,TResult? Function( String ip,  String inviteId,  String groupId,  String groupName,  String senderDeviceId,  String senderAlias,  String role,  String createdAt,  String? expiresAt)?  homeHubInviteRequest,TResult? Function( String eventId,  String groupId,  String senderDeviceId,  String senderAlias,  String text,  String createdAt)?  homeHubChatMessage,TResult? Function( String ip,  String offerId,  String groupId,  String senderDeviceId,  String senderAlias,  List<RsHomeHubTransferFile> files)?  homeHubTransferOffer,TResult? Function( String error)?  listenerFailed,}) {final _that = this;
switch (_that) {
case RsServerEvent_Register() when register != null:
return register(_that.ip,_that.info);case RsServerEvent_PrepareUpload() when prepareUpload != null:
return prepareUpload(_that.sessionId,_that.ip,_that.info,_that.certFingerprint,_that.files);case RsServerEvent_FileUpload() when fileUpload != null:
return fileUpload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_SessionEnd() when sessionEnd != null:
return sessionEnd(_that.sessionId,_that.reason);case RsServerEvent_PrepareUploadAborted() when prepareUploadAborted != null:
return prepareUploadAborted(_that.sessionId);case RsServerEvent_CancelReceived() when cancelReceived != null:
return cancelReceived(_that.ip,_that.sessionId);case RsServerEvent_WebPrepareDownload() when webPrepareDownload != null:
return webPrepareDownload(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_WebFileDownload() when webFileDownload != null:
return webFileDownload(_that.sessionId,_that.fileId,_that.file);case RsServerEvent_StreamPrepareSession() when streamPrepareSession != null:
return streamPrepareSession(_that.ip,_that.sessionId,_that.userAgent);case RsServerEvent_StreamFileRequest() when streamFileRequest != null:
return streamFileRequest(_that.ip,_that.sessionId,_that.requestId,_that.entry,_that.purpose);case RsServerEvent_Show() when show_ != null:
return show_(_that.args);case RsServerEvent_HomeHubInviteRequest() when homeHubInviteRequest != null:
return homeHubInviteRequest(_that.ip,_that.inviteId,_that.groupId,_that.groupName,_that.senderDeviceId,_that.senderAlias,_that.role,_that.createdAt,_that.expiresAt);case RsServerEvent_HomeHubChatMessage() when homeHubChatMessage != null:
return homeHubChatMessage(_that.eventId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.text,_that.createdAt);case RsServerEvent_HomeHubTransferOffer() when homeHubTransferOffer != null:
return homeHubTransferOffer(_that.ip,_that.offerId,_that.groupId,_that.senderDeviceId,_that.senderAlias,_that.files);case RsServerEvent_ListenerFailed() when listenerFailed != null:
return listenerFailed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class RsServerEvent_Register extends RsServerEvent {
  const RsServerEvent_Register({required this.ip, required this.info}): super._();


 final  String ip;
 final  RegisterDtoV2 info;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_RegisterCopyWith<RsServerEvent_Register> get copyWith => _$RsServerEvent_RegisterCopyWithImpl<RsServerEvent_Register>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_Register&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.info, info) || other.info == info));
}


@override
int get hashCode => Object.hash(runtimeType,ip,info);

@override
String toString() {
  return 'RsServerEvent.register(ip: $ip, info: $info)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_RegisterCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_RegisterCopyWith(RsServerEvent_Register value, $Res Function(RsServerEvent_Register) _then) = _$RsServerEvent_RegisterCopyWithImpl;
@useResult
$Res call({
 String ip, RegisterDtoV2 info
});




}
/// @nodoc
class _$RsServerEvent_RegisterCopyWithImpl<$Res>
    implements $RsServerEvent_RegisterCopyWith<$Res> {
  _$RsServerEvent_RegisterCopyWithImpl(this._self, this._then);

  final RsServerEvent_Register _self;
  final $Res Function(RsServerEvent_Register) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? info = null,}) {
  return _then(RsServerEvent_Register(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RegisterDtoV2,
  ));
}


}

/// @nodoc


class RsServerEvent_PrepareUpload extends RsServerEvent {
  const RsServerEvent_PrepareUpload({required this.sessionId, required this.ip, required this.info, this.certFingerprint, required final  Map<String, FileDto> files}): _files = files,super._();


/// The session ID the upload session will have when the request is accepted.
 final  String sessionId;
 final  String ip;
 final  RegisterDtoV2 info;
/// The SHA-256 fingerprint (uppercase hex) of the sender's client
/// certificate verified during the mTLS handshake. Unlike
/// `info.fingerprint`, this value cannot be spoofed.
/// `None` when the server runs without TLS.
 final  String? certFingerprint;
 final  Map<String, FileDto> _files;
 Map<String, FileDto> get files {
  if (_files is EqualUnmodifiableMapView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_files);
}


/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_PrepareUploadCopyWith<RsServerEvent_PrepareUpload> get copyWith => _$RsServerEvent_PrepareUploadCopyWithImpl<RsServerEvent_PrepareUpload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_PrepareUpload&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.info, info) || other.info == info)&&(identical(other.certFingerprint, certFingerprint) || other.certFingerprint == certFingerprint)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,ip,info,certFingerprint,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'RsServerEvent.prepareUpload(sessionId: $sessionId, ip: $ip, info: $info, certFingerprint: $certFingerprint, files: $files)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_PrepareUploadCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_PrepareUploadCopyWith(RsServerEvent_PrepareUpload value, $Res Function(RsServerEvent_PrepareUpload) _then) = _$RsServerEvent_PrepareUploadCopyWithImpl;
@useResult
$Res call({
 String sessionId, String ip, RegisterDtoV2 info, String? certFingerprint, Map<String, FileDto> files
});




}
/// @nodoc
class _$RsServerEvent_PrepareUploadCopyWithImpl<$Res>
    implements $RsServerEvent_PrepareUploadCopyWith<$Res> {
  _$RsServerEvent_PrepareUploadCopyWithImpl(this._self, this._then);

  final RsServerEvent_PrepareUpload _self;
  final $Res Function(RsServerEvent_PrepareUpload) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? ip = null,Object? info = null,Object? certFingerprint = freezed,Object? files = null,}) {
  return _then(RsServerEvent_PrepareUpload(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as RegisterDtoV2,certFingerprint: freezed == certFingerprint ? _self.certFingerprint : certFingerprint // ignore: cast_nullable_to_non_nullable
as String?,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as Map<String, FileDto>,
  ));
}


}

/// @nodoc


class RsServerEvent_FileUpload extends RsServerEvent {
  const RsServerEvent_FileUpload({required this.sessionId, required this.fileId, required this.file}): super._();


 final  String sessionId;
 final  String fileId;
 final  FileDto file;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_FileUploadCopyWith<RsServerEvent_FileUpload> get copyWith => _$RsServerEvent_FileUploadCopyWithImpl<RsServerEvent_FileUpload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_FileUpload&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,fileId,file);

@override
String toString() {
  return 'RsServerEvent.fileUpload(sessionId: $sessionId, fileId: $fileId, file: $file)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_FileUploadCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_FileUploadCopyWith(RsServerEvent_FileUpload value, $Res Function(RsServerEvent_FileUpload) _then) = _$RsServerEvent_FileUploadCopyWithImpl;
@useResult
$Res call({
 String sessionId, String fileId, FileDto file
});




}
/// @nodoc
class _$RsServerEvent_FileUploadCopyWithImpl<$Res>
    implements $RsServerEvent_FileUploadCopyWith<$Res> {
  _$RsServerEvent_FileUploadCopyWithImpl(this._self, this._then);

  final RsServerEvent_FileUpload _self;
  final $Res Function(RsServerEvent_FileUpload) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? fileId = null,Object? file = null,}) {
  return _then(RsServerEvent_FileUpload(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as FileDto,
  ));
}


}

/// @nodoc


class RsServerEvent_SessionEnd extends RsServerEvent {
  const RsServerEvent_SessionEnd({required this.sessionId, required this.reason}): super._();


 final  String sessionId;
 final  SessionEndReasonV2 reason;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_SessionEndCopyWith<RsServerEvent_SessionEnd> get copyWith => _$RsServerEvent_SessionEndCopyWithImpl<RsServerEvent_SessionEnd>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_SessionEnd&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,reason);

@override
String toString() {
  return 'RsServerEvent.sessionEnd(sessionId: $sessionId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_SessionEndCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_SessionEndCopyWith(RsServerEvent_SessionEnd value, $Res Function(RsServerEvent_SessionEnd) _then) = _$RsServerEvent_SessionEndCopyWithImpl;
@useResult
$Res call({
 String sessionId, SessionEndReasonV2 reason
});




}
/// @nodoc
class _$RsServerEvent_SessionEndCopyWithImpl<$Res>
    implements $RsServerEvent_SessionEndCopyWith<$Res> {
  _$RsServerEvent_SessionEndCopyWithImpl(this._self, this._then);

  final RsServerEvent_SessionEnd _self;
  final $Res Function(RsServerEvent_SessionEnd) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? reason = null,}) {
  return _then(RsServerEvent_SessionEnd(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SessionEndReasonV2,
  ));
}


}

/// @nodoc


class RsServerEvent_PrepareUploadAborted extends RsServerEvent {
  const RsServerEvent_PrepareUploadAborted({required this.sessionId}): super._();


 final  String sessionId;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_PrepareUploadAbortedCopyWith<RsServerEvent_PrepareUploadAborted> get copyWith => _$RsServerEvent_PrepareUploadAbortedCopyWithImpl<RsServerEvent_PrepareUploadAborted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_PrepareUploadAborted&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'RsServerEvent.prepareUploadAborted(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_PrepareUploadAbortedCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_PrepareUploadAbortedCopyWith(RsServerEvent_PrepareUploadAborted value, $Res Function(RsServerEvent_PrepareUploadAborted) _then) = _$RsServerEvent_PrepareUploadAbortedCopyWithImpl;
@useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class _$RsServerEvent_PrepareUploadAbortedCopyWithImpl<$Res>
    implements $RsServerEvent_PrepareUploadAbortedCopyWith<$Res> {
  _$RsServerEvent_PrepareUploadAbortedCopyWithImpl(this._self, this._then);

  final RsServerEvent_PrepareUploadAborted _self;
  final $Res Function(RsServerEvent_PrepareUploadAborted) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,}) {
  return _then(RsServerEvent_PrepareUploadAborted(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RsServerEvent_CancelReceived extends RsServerEvent {
  const RsServerEvent_CancelReceived({required this.ip, required this.sessionId}): super._();


 final  String ip;
 final  String sessionId;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_CancelReceivedCopyWith<RsServerEvent_CancelReceived> get copyWith => _$RsServerEvent_CancelReceivedCopyWithImpl<RsServerEvent_CancelReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_CancelReceived&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,ip,sessionId);

@override
String toString() {
  return 'RsServerEvent.cancelReceived(ip: $ip, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_CancelReceivedCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_CancelReceivedCopyWith(RsServerEvent_CancelReceived value, $Res Function(RsServerEvent_CancelReceived) _then) = _$RsServerEvent_CancelReceivedCopyWithImpl;
@useResult
$Res call({
 String ip, String sessionId
});




}
/// @nodoc
class _$RsServerEvent_CancelReceivedCopyWithImpl<$Res>
    implements $RsServerEvent_CancelReceivedCopyWith<$Res> {
  _$RsServerEvent_CancelReceivedCopyWithImpl(this._self, this._then);

  final RsServerEvent_CancelReceived _self;
  final $Res Function(RsServerEvent_CancelReceived) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? sessionId = null,}) {
  return _then(RsServerEvent_CancelReceived(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RsServerEvent_WebPrepareDownload extends RsServerEvent {
  const RsServerEvent_WebPrepareDownload({required this.ip, required this.sessionId, this.userAgent}): super._();


 final  String ip;
 final  String sessionId;
 final  String? userAgent;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_WebPrepareDownloadCopyWith<RsServerEvent_WebPrepareDownload> get copyWith => _$RsServerEvent_WebPrepareDownloadCopyWithImpl<RsServerEvent_WebPrepareDownload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_WebPrepareDownload&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}


@override
int get hashCode => Object.hash(runtimeType,ip,sessionId,userAgent);

@override
String toString() {
  return 'RsServerEvent.webPrepareDownload(ip: $ip, sessionId: $sessionId, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_WebPrepareDownloadCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_WebPrepareDownloadCopyWith(RsServerEvent_WebPrepareDownload value, $Res Function(RsServerEvent_WebPrepareDownload) _then) = _$RsServerEvent_WebPrepareDownloadCopyWithImpl;
@useResult
$Res call({
 String ip, String sessionId, String? userAgent
});




}
/// @nodoc
class _$RsServerEvent_WebPrepareDownloadCopyWithImpl<$Res>
    implements $RsServerEvent_WebPrepareDownloadCopyWith<$Res> {
  _$RsServerEvent_WebPrepareDownloadCopyWithImpl(this._self, this._then);

  final RsServerEvent_WebPrepareDownload _self;
  final $Res Function(RsServerEvent_WebPrepareDownload) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? sessionId = null,Object? userAgent = freezed,}) {
  return _then(RsServerEvent_WebPrepareDownload(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RsServerEvent_WebFileDownload extends RsServerEvent {
  const RsServerEvent_WebFileDownload({required this.sessionId, required this.fileId, required this.file}): super._();


 final  String sessionId;
 final  String fileId;
 final  FileDto file;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_WebFileDownloadCopyWith<RsServerEvent_WebFileDownload> get copyWith => _$RsServerEvent_WebFileDownloadCopyWithImpl<RsServerEvent_WebFileDownload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_WebFileDownload&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,fileId,file);

@override
String toString() {
  return 'RsServerEvent.webFileDownload(sessionId: $sessionId, fileId: $fileId, file: $file)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_WebFileDownloadCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_WebFileDownloadCopyWith(RsServerEvent_WebFileDownload value, $Res Function(RsServerEvent_WebFileDownload) _then) = _$RsServerEvent_WebFileDownloadCopyWithImpl;
@useResult
$Res call({
 String sessionId, String fileId, FileDto file
});




}
/// @nodoc
class _$RsServerEvent_WebFileDownloadCopyWithImpl<$Res>
    implements $RsServerEvent_WebFileDownloadCopyWith<$Res> {
  _$RsServerEvent_WebFileDownloadCopyWithImpl(this._self, this._then);

  final RsServerEvent_WebFileDownload _self;
  final $Res Function(RsServerEvent_WebFileDownload) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? fileId = null,Object? file = null,}) {
  return _then(RsServerEvent_WebFileDownload(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as FileDto,
  ));
}


}

/// @nodoc


class RsServerEvent_StreamPrepareSession extends RsServerEvent {
  const RsServerEvent_StreamPrepareSession({required this.ip, required this.sessionId, this.userAgent}): super._();


 final  String ip;
 final  String sessionId;
 final  String? userAgent;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_StreamPrepareSessionCopyWith<RsServerEvent_StreamPrepareSession> get copyWith => _$RsServerEvent_StreamPrepareSessionCopyWithImpl<RsServerEvent_StreamPrepareSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_StreamPrepareSession&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}


@override
int get hashCode => Object.hash(runtimeType,ip,sessionId,userAgent);

@override
String toString() {
  return 'RsServerEvent.streamPrepareSession(ip: $ip, sessionId: $sessionId, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_StreamPrepareSessionCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_StreamPrepareSessionCopyWith(RsServerEvent_StreamPrepareSession value, $Res Function(RsServerEvent_StreamPrepareSession) _then) = _$RsServerEvent_StreamPrepareSessionCopyWithImpl;
@useResult
$Res call({
 String ip, String sessionId, String? userAgent
});




}
/// @nodoc
class _$RsServerEvent_StreamPrepareSessionCopyWithImpl<$Res>
    implements $RsServerEvent_StreamPrepareSessionCopyWith<$Res> {
  _$RsServerEvent_StreamPrepareSessionCopyWithImpl(this._self, this._then);

  final RsServerEvent_StreamPrepareSession _self;
  final $Res Function(RsServerEvent_StreamPrepareSession) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? sessionId = null,Object? userAgent = freezed,}) {
  return _then(RsServerEvent_StreamPrepareSession(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RsServerEvent_StreamFileRequest extends RsServerEvent {
  const RsServerEvent_StreamFileRequest({required this.ip, required this.sessionId, required this.requestId, required this.entry, required this.purpose}): super._();


 final  String ip;
 final  String sessionId;
 final  String requestId;
 final  RsStreamEntry entry;
 final  String purpose;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_StreamFileRequestCopyWith<RsServerEvent_StreamFileRequest> get copyWith => _$RsServerEvent_StreamFileRequestCopyWithImpl<RsServerEvent_StreamFileRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_StreamFileRequest&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}


@override
int get hashCode => Object.hash(runtimeType,ip,sessionId,requestId,entry,purpose);

@override
String toString() {
  return 'RsServerEvent.streamFileRequest(ip: $ip, sessionId: $sessionId, requestId: $requestId, entry: $entry, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_StreamFileRequestCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_StreamFileRequestCopyWith(RsServerEvent_StreamFileRequest value, $Res Function(RsServerEvent_StreamFileRequest) _then) = _$RsServerEvent_StreamFileRequestCopyWithImpl;
@useResult
$Res call({
 String ip, String sessionId, String requestId, RsStreamEntry entry, String purpose
});




}
/// @nodoc
class _$RsServerEvent_StreamFileRequestCopyWithImpl<$Res>
    implements $RsServerEvent_StreamFileRequestCopyWith<$Res> {
  _$RsServerEvent_StreamFileRequestCopyWithImpl(this._self, this._then);

  final RsServerEvent_StreamFileRequest _self;
  final $Res Function(RsServerEvent_StreamFileRequest) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? sessionId = null,Object? requestId = null,Object? entry = null,Object? purpose = null,}) {
  return _then(RsServerEvent_StreamFileRequest(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as RsStreamEntry,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RsServerEvent_Show extends RsServerEvent {
  const RsServerEvent_Show({required final  List<String> args}): _args = args,super._();


/// Command-line arguments forwarded by the other application instance.
 final  List<String> _args;
/// Command-line arguments forwarded by the other application instance.
 List<String> get args {
  if (_args is EqualUnmodifiableListView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_args);
}


/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_ShowCopyWith<RsServerEvent_Show> get copyWith => _$RsServerEvent_ShowCopyWithImpl<RsServerEvent_Show>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_Show&&const DeepCollectionEquality().equals(other._args, _args));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_args));

@override
String toString() {
  return 'RsServerEvent.show_(args: $args)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_ShowCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_ShowCopyWith(RsServerEvent_Show value, $Res Function(RsServerEvent_Show) _then) = _$RsServerEvent_ShowCopyWithImpl;
@useResult
$Res call({
 List<String> args
});




}
/// @nodoc
class _$RsServerEvent_ShowCopyWithImpl<$Res>
    implements $RsServerEvent_ShowCopyWith<$Res> {
  _$RsServerEvent_ShowCopyWithImpl(this._self, this._then);

  final RsServerEvent_Show _self;
  final $Res Function(RsServerEvent_Show) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? args = null,}) {
  return _then(RsServerEvent_Show(
args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class RsServerEvent_HomeHubInviteRequest extends RsServerEvent {
  const RsServerEvent_HomeHubInviteRequest({required this.ip, required this.inviteId, required this.groupId, required this.groupName, required this.senderDeviceId, required this.senderAlias, required this.role, required this.createdAt, this.expiresAt}): super._();


 final  String ip;
 final  String inviteId;
 final  String groupId;
 final  String groupName;
 final  String senderDeviceId;
 final  String senderAlias;
 final  String role;
 final  String createdAt;
 final  String? expiresAt;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_HomeHubInviteRequestCopyWith<RsServerEvent_HomeHubInviteRequest> get copyWith => _$RsServerEvent_HomeHubInviteRequestCopyWithImpl<RsServerEvent_HomeHubInviteRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_HomeHubInviteRequest&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.inviteId, inviteId) || other.inviteId == inviteId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.senderAlias, senderAlias) || other.senderAlias == senderAlias)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,ip,inviteId,groupId,groupName,senderDeviceId,senderAlias,role,createdAt,expiresAt);

@override
String toString() {
  return 'RsServerEvent.homeHubInviteRequest(ip: $ip, inviteId: $inviteId, groupId: $groupId, groupName: $groupName, senderDeviceId: $senderDeviceId, senderAlias: $senderAlias, role: $role, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_HomeHubInviteRequestCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_HomeHubInviteRequestCopyWith(RsServerEvent_HomeHubInviteRequest value, $Res Function(RsServerEvent_HomeHubInviteRequest) _then) = _$RsServerEvent_HomeHubInviteRequestCopyWithImpl;
@useResult
$Res call({
 String ip, String inviteId, String groupId, String groupName, String senderDeviceId, String senderAlias, String role, String createdAt, String? expiresAt
});




}
/// @nodoc
class _$RsServerEvent_HomeHubInviteRequestCopyWithImpl<$Res>
    implements $RsServerEvent_HomeHubInviteRequestCopyWith<$Res> {
  _$RsServerEvent_HomeHubInviteRequestCopyWithImpl(this._self, this._then);

  final RsServerEvent_HomeHubInviteRequest _self;
  final $Res Function(RsServerEvent_HomeHubInviteRequest) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? inviteId = null,Object? groupId = null,Object? groupName = null,Object? senderDeviceId = null,Object? senderAlias = null,Object? role = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(RsServerEvent_HomeHubInviteRequest(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,inviteId: null == inviteId ? _self.inviteId : inviteId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,senderAlias: null == senderAlias ? _self.senderAlias : senderAlias // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RsServerEvent_HomeHubChatMessage extends RsServerEvent {
  const RsServerEvent_HomeHubChatMessage({required this.eventId, required this.groupId, required this.senderDeviceId, required this.senderAlias, required this.text, required this.createdAt}): super._();


 final  String eventId;
 final  String groupId;
 final  String senderDeviceId;
 final  String senderAlias;
 final  String text;
 final  String createdAt;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_HomeHubChatMessageCopyWith<RsServerEvent_HomeHubChatMessage> get copyWith => _$RsServerEvent_HomeHubChatMessageCopyWithImpl<RsServerEvent_HomeHubChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_HomeHubChatMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.senderAlias, senderAlias) || other.senderAlias == senderAlias)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,eventId,groupId,senderDeviceId,senderAlias,text,createdAt);

@override
String toString() {
  return 'RsServerEvent.homeHubChatMessage(eventId: $eventId, groupId: $groupId, senderDeviceId: $senderDeviceId, senderAlias: $senderAlias, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_HomeHubChatMessageCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_HomeHubChatMessageCopyWith(RsServerEvent_HomeHubChatMessage value, $Res Function(RsServerEvent_HomeHubChatMessage) _then) = _$RsServerEvent_HomeHubChatMessageCopyWithImpl;
@useResult
$Res call({
 String eventId, String groupId, String senderDeviceId, String senderAlias, String text, String createdAt
});




}
/// @nodoc
class _$RsServerEvent_HomeHubChatMessageCopyWithImpl<$Res>
    implements $RsServerEvent_HomeHubChatMessageCopyWith<$Res> {
  _$RsServerEvent_HomeHubChatMessageCopyWithImpl(this._self, this._then);

  final RsServerEvent_HomeHubChatMessage _self;
  final $Res Function(RsServerEvent_HomeHubChatMessage) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? groupId = null,Object? senderDeviceId = null,Object? senderAlias = null,Object? text = null,Object? createdAt = null,}) {
  return _then(RsServerEvent_HomeHubChatMessage(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,senderAlias: null == senderAlias ? _self.senderAlias : senderAlias // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RsServerEvent_HomeHubTransferOffer extends RsServerEvent {
  const RsServerEvent_HomeHubTransferOffer({required this.ip, required this.offerId, required this.groupId, required this.senderDeviceId, required this.senderAlias, required final  List<RsHomeHubTransferFile> files}): _files = files,super._();


 final  String ip;
 final  String offerId;
 final  String groupId;
 final  String senderDeviceId;
 final  String senderAlias;
 final  List<RsHomeHubTransferFile> _files;
 List<RsHomeHubTransferFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_HomeHubTransferOfferCopyWith<RsServerEvent_HomeHubTransferOffer> get copyWith => _$RsServerEvent_HomeHubTransferOfferCopyWithImpl<RsServerEvent_HomeHubTransferOffer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_HomeHubTransferOffer&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.senderAlias, senderAlias) || other.senderAlias == senderAlias)&&const DeepCollectionEquality().equals(other._files, _files));
}


@override
int get hashCode => Object.hash(runtimeType,ip,offerId,groupId,senderDeviceId,senderAlias,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'RsServerEvent.homeHubTransferOffer(ip: $ip, offerId: $offerId, groupId: $groupId, senderDeviceId: $senderDeviceId, senderAlias: $senderAlias, files: $files)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_HomeHubTransferOfferCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_HomeHubTransferOfferCopyWith(RsServerEvent_HomeHubTransferOffer value, $Res Function(RsServerEvent_HomeHubTransferOffer) _then) = _$RsServerEvent_HomeHubTransferOfferCopyWithImpl;
@useResult
$Res call({
 String ip, String offerId, String groupId, String senderDeviceId, String senderAlias, List<RsHomeHubTransferFile> files
});




}
/// @nodoc
class _$RsServerEvent_HomeHubTransferOfferCopyWithImpl<$Res>
    implements $RsServerEvent_HomeHubTransferOfferCopyWith<$Res> {
  _$RsServerEvent_HomeHubTransferOfferCopyWithImpl(this._self, this._then);

  final RsServerEvent_HomeHubTransferOffer _self;
  final $Res Function(RsServerEvent_HomeHubTransferOffer) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? offerId = null,Object? groupId = null,Object? senderDeviceId = null,Object? senderAlias = null,Object? files = null,}) {
  return _then(RsServerEvent_HomeHubTransferOffer(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,senderAlias: null == senderAlias ? _self.senderAlias : senderAlias // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<RsHomeHubTransferFile>,
  ));
}


}

/// @nodoc


class RsServerEvent_ListenerFailed extends RsServerEvent {
  const RsServerEvent_ListenerFailed({required this.error}): super._();


/// Description of the failure.
 final  String error;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsServerEvent_ListenerFailedCopyWith<RsServerEvent_ListenerFailed> get copyWith => _$RsServerEvent_ListenerFailedCopyWithImpl<RsServerEvent_ListenerFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsServerEvent_ListenerFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'RsServerEvent.listenerFailed(error: $error)';
}


}

/// @nodoc
abstract mixin class $RsServerEvent_ListenerFailedCopyWith<$Res> implements $RsServerEventCopyWith<$Res> {
  factory $RsServerEvent_ListenerFailedCopyWith(RsServerEvent_ListenerFailed value, $Res Function(RsServerEvent_ListenerFailed) _then) = _$RsServerEvent_ListenerFailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$RsServerEvent_ListenerFailedCopyWithImpl<$Res>
    implements $RsServerEvent_ListenerFailedCopyWith<$Res> {
  _$RsServerEvent_ListenerFailedCopyWithImpl(this._self, this._then);

  final RsServerEvent_ListenerFailed _self;
  final $Res Function(RsServerEvent_ListenerFailed) _then;

/// Create a copy of RsServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(RsServerEvent_ListenerFailed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
