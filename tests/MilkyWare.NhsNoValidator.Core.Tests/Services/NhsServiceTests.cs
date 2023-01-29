using Xunit;
using MilkyWare.NhsNoValidator.Core.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NSubstitute;
using Microsoft.Extensions.Logging;

namespace MilkyWare.NhsNoValidator.Core.Services.Tests
{
    public class NhsServiceTests
    {
        private readonly INhsService _nhsService;

        public NhsServiceTests()
        {
            var logger = Substitute.For<ILogger<NhsService>>();
            _nhsService = new NhsService(logger);
        }

        [Theory()]
        [InlineData("999 397 2851")]
        [InlineData("9993972851")]
        public void ValidateNhsNoTest_Valid(string number)
        {
            var result = _nhsService.ValidateNhsNo(number);
            Assert.True(result);
        }

        [Theory()]
        [InlineData("999 123")]
        [InlineData("1234567890987654321")]
        [InlineData("999 397 2866")]
        public void ValidateNhsNoTest_Invalid(string number)
        {
            var result = _nhsService.ValidateNhsNo(number);
            Assert.False(result);
        }
    }
}