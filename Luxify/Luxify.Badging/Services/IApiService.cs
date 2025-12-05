using Luxify.Core;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Luxify.Badging.Services;

public interface IApiService
{
    Task<Dictionary<string, PulseStatus>> CheckPulseAsync(PulseRequest request);
}
