using Luxify.Core;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Luxify.Badging.Services;

public class MockApiService : IApiService
{
    public async Task<Dictionary<string, PulseStatus>> CheckPulseAsync(PulseRequest request)
    {
        // Simulate network delay
        await Task.Delay(500);

        var result = new Dictionary<string, PulseStatus>();
        var random = new Random();

        foreach (var badgeCode in request.Badges)
        {
            // Simulate some logic:
            // PL1 is always dirty (Client change)
            // PL3 is always critical (Stock issue)
            // Others are random-ish or clean
            
            if (badgeCode == "PL1")
            {
                result[badgeCode] = new PulseStatus 
                { 
                    IsSpecDirty = true, 
                    IsStockCritical = false,
                    Message = "Spec changed to PL2 on 12/04"
                };
            }
            else if (badgeCode == "PL3")
            {
                result[badgeCode] = new PulseStatus 
                { 
                    IsSpecDirty = false, 
                    IsStockCritical = true,
                    Message = "Backordered: 4 weeks"
                };
            }
            else
            {
                // Default clean
                result[badgeCode] = new PulseStatus 
                { 
                    IsSpecDirty = false, 
                    IsStockCritical = false 
                };
            }
        }

        return result;
    }
}
