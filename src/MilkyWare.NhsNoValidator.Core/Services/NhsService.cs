using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkyWare.NhsNoValidator.Core.Services
{
    public class NhsService : INhsService
    {
        private readonly ILogger<NhsService> _logger;

        public NhsService(ILogger<NhsService> logger)
        {
            _logger = logger;
        }

        public bool ValidateNhsNo(string number)
        {
            if (string.IsNullOrWhiteSpace(number))
            {
                _logger.LogWarning("Empty NHS No provided", number);
                return false;
            }

            _logger.LogTrace("Sanitizing {nhsNo}", number);
            number = number.Replace(" ", "");

            if (number.Length != 10)
            {
                _logger.LogWarning("NHS No not 10 digits long", number);
                return false;
            }

            _logger.LogInformation("Validating {nhsNo}", number);

            foreach (var n in number)
            {
                if (!int.TryParse(n.ToString(), out int parsed))
                    return false;
            }

            int sum = 0;
            for (int i = 0; i < number.Length - 1; i++)
            {
                var digit = int.Parse(number[i].ToString());
                _logger.LogDebug("digit={digit}", digit);

                var weightFactor = 10 - i;
                _logger.LogDebug("weightFactor={weightFactor}", weightFactor);

                sum += digit * weightFactor;
            }
            _logger.LogDebug("sum={sum}", sum);

            var remainder = sum % 11;
            _logger.LogDebug("remainder={remainder}", remainder);

            var checkDigit = 11 - remainder;
            _logger.LogDebug("checkDigit={checkDigit}", checkDigit);

            if (checkDigit == 10)
            {
                _logger.LogTrace("Check digit calculated as 10, invalid");
                return false;
            }

            if (checkDigit == 11)
            {
                _logger.LogTrace("Check digit calculated as 11, resetting to 0");
                checkDigit = 0;
            }

            var lastDigit = int.Parse(number[number.Length - 1].ToString());
            var valid = lastDigit == checkDigit;

            _logger.LogInformation("{nhsNo} valid: {valid}", number, valid);
            return valid;
        }
    }
}
