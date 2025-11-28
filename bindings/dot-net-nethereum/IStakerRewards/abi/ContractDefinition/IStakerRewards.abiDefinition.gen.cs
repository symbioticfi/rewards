using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts;
using System.Threading;

namespace Symbiotic.Relay.IStakerRewards.abi.ContractDefinition
{


    public partial class IStakerRewards.abiDeployment : IStakerRewards.abiDeploymentBase
    {
        public IStakerRewards.abiDeployment() : base(BYTECODE) { }
        public IStakerRewards.abiDeployment(string byteCode) : base(byteCode) { }
    }

    public class IStakerRewards.abiDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "";
        public IStakerRewards.abiDeploymentBase() : base(BYTECODE) { }
        public IStakerRewards.abiDeploymentBase(string byteCode) : base(byteCode) { }

    }

    public partial class ClaimRewardsFunction : ClaimRewardsFunctionBase { }

    [Function("claimRewards")]
    public class ClaimRewardsFunctionBase : FunctionMessage
    {
        [Parameter("address", "recipient", 1)]
        public virtual string Recipient { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
        [Parameter("bytes", "data", 3)]
        public virtual byte[] Data { get; set; }
    }

    public partial class ClaimableFunction : ClaimableFunctionBase { }

    [Function("claimable", "uint256")]
    public class ClaimableFunctionBase : FunctionMessage
    {
        [Parameter("address", "token", 1)]
        public virtual string Token { get; set; }
        [Parameter("address", "account", 2)]
        public virtual string Account { get; set; }
        [Parameter("bytes", "data", 3)]
        public virtual byte[] Data { get; set; }
    }

    public partial class DistributeRewardsFunction : DistributeRewardsFunctionBase { }

    [Function("distributeRewards")]
    public class DistributeRewardsFunctionBase : FunctionMessage
    {
        [Parameter("address", "network", 1)]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
        [Parameter("uint256", "amount", 3)]
        public virtual BigInteger Amount { get; set; }
        [Parameter("bytes", "data", 4)]
        public virtual byte[] Data { get; set; }
    }

    public partial class VersionFunction : VersionFunctionBase { }

    [Function("version", "uint64")]
    public class VersionFunctionBase : FunctionMessage
    {

    }

    public partial class ClaimRewardsEventDTO : ClaimRewardsEventDTOBase { }

    [Event("ClaimRewards")]
    public class ClaimRewardsEventDTOBase : IEventDTO
    {
        [Parameter("address", "network", 1, true )]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2, true )]
        public virtual string Token { get; set; }
        [Parameter("address", "claimer", 3, true )]
        public virtual string Claimer { get; set; }
        [Parameter("uint256", "amount", 4, false )]
        public virtual BigInteger Amount { get; set; }
        [Parameter("address", "recipient", 5, false )]
        public virtual string Recipient { get; set; }
    }

    public partial class DistributeRewardsEventDTO : DistributeRewardsEventDTOBase { }

    [Event("DistributeRewards")]
    public class DistributeRewardsEventDTOBase : IEventDTO
    {
        [Parameter("address", "network", 1, true )]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2, true )]
        public virtual string Token { get; set; }
        [Parameter("uint256", "distributeAmount", 3, false )]
        public virtual BigInteger DistributeAmount { get; set; }
        [Parameter("uint256", "adminFeeAmount", 4, false )]
        public virtual BigInteger AdminFeeAmount { get; set; }
        [Parameter("uint48", "timestamp", 5, false )]
        public virtual ulong Timestamp { get; set; }
    }



    public partial class ClaimableOutputDTO : ClaimableOutputDTOBase { }

    [FunctionOutput]
    public class ClaimableOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }



    public partial class VersionOutputDTO : VersionOutputDTOBase { }

    [FunctionOutput]
    public class VersionOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint64", "", 1)]
        public virtual ulong ReturnValue1 { get; set; }
    }
}
