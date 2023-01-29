using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkyWare.NhsNoValidator.Core.Services
{
    public interface INhsService
    {
        public bool ValidateNhsNo(string value);
    }
}
