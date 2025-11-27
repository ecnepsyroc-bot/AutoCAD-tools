using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace FeatureMillwork.CommandBridge.Shared.Messages;

/// <summary>
/// Base message for all bridge communications
/// </summary>
public class BridgeMessage
{
    [JsonProperty("type")]
    [JsonConverter(typeof(StringEnumConverter))]
    public MessageType Type { get; set; }

    [JsonProperty("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.Now;

    [JsonProperty("command")]
    public string? Command { get; set; }

    [JsonProperty("message")]
    public string? Message { get; set; }

    [JsonProperty("error")]
    public string? Error { get; set; }

    [JsonProperty("variable")]
    public string? Variable { get; set; }

    [JsonProperty("value")]
    public object? Value { get; set; }

    [JsonProperty("drawing")]
    public string? Drawing { get; set; }

    [JsonProperty("version")]
    public string? Version { get; set; }

    [JsonProperty("autocadVersion")]
    public string? AutoCADVersion { get; set; }

    [JsonProperty("firstExpression")]
    public string? FirstExpression { get; set; }

    [JsonProperty("defaultValue")]
    public string? DefaultValue { get; set; }
}

public enum MessageType
{
    [JsonProperty("connected")]
    Connected,

    [JsonProperty("shutdown")]
    Shutdown,

    [JsonProperty("command_start")]
    CommandStart,

    [JsonProperty("command_end")]
    CommandEnd,

    [JsonProperty("command_cancelled")]
    CommandCancelled,

    [JsonProperty("command_failed")]
    CommandFailed,

    [JsonProperty("lisp_start")]
    LispStart,

    [JsonProperty("lisp_end")]
    LispEnd,

    [JsonProperty("lisp_cancelled")]
    LispCancelled,

    [JsonProperty("prompt_string")]
    PromptString,

    [JsonProperty("prompt_point")]
    PromptPoint,

    [JsonProperty("prompt_selection")]
    PromptSelection,

    [JsonProperty("error")]
    Error,

    [JsonProperty("test")]
    Test,

    [JsonProperty("sysvar")]
    SysVar,

    [JsonProperty("sysvar_set")]
    SysVarSet,

    [JsonProperty("pong")]
    Pong,

    [JsonProperty("execute")]
    Execute,

    [JsonProperty("lisp")]
    Lisp,

    [JsonProperty("getvar")]
    GetVar,

    [JsonProperty("setvar")]
    SetVar,

    [JsonProperty("ping")]
    Ping
}
