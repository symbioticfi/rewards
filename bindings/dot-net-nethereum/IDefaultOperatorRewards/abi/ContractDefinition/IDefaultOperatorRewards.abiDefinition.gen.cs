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

namespace Symbiotic.Relay.IDefaultOperatorRewards.abi.ContractDefinition
{


    public partial class IDefaultOperatorRewards.abiDeployment : IDefaultOperatorRewards.abiDeploymentBase
    {
        public IDefaultOperatorRewards.abiDeployment() : base(BYTECODE) { }
        public IDefaultOperatorRewards.abiDeployment(string byteCode) : base(byteCode) { }
    }

    public class IDefaultOperatorRewards.abiDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "";
        public IDefaultOperatorRewards.abiDeploymentBase() : base(BYTECODE) { }
        public IDefaultOperatorRewards.abiDeploymentBase(string byteCode) : base(byteCode) { }

    }

    public partial class NetworkMiddlewareServiceFunction : NetworkMiddlewareServiceFunctionBase { }

    [Function("NETWORK_MIDDLEWARE_SERVICE", "address")]
    public class NetworkMiddlewareServiceFunctionBase : FunctionMessage
    {

    }

    public partial class BalanceFunction : BalanceFunctionBase { }

    [Function("balance", "uint256")]
    public class BalanceFunctionBase : FunctionMessage
    {
        [Parameter("address", "network", 1)]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
    }

    public partial class ClaimRewardsFunction : ClaimRewardsFunctionBase { }

    [Function("claimRewards", "uint256")]
    public class ClaimRewardsFunctionBase : FunctionMessage
    {
        [Parameter("address", "recipient", 1)]
        public virtual string Recipient { get; set; }
        [Parameter("address", "network", 2)]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 3)]
        public virtual string Token { get; set; }
        [Parameter("uint256", "totalClaimable", 4)]
        public virtual BigInteger TotalClaimable { get; set; }
        [Parameter("bytes32[]", "proof", 5)]
        public virtual List<byte[]> Proof { get; set; }
    }

    public partial class ClaimedFunction : ClaimedFunctionBase { }

    [Function("claimed", "uint256")]
    public class ClaimedFunctionBase : FunctionMessage
    {
        [Parameter("address", "network", 1)]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
        [Parameter("address", "account", 3)]
        public virtual string Account { get; set; }
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
        [Parameter("bytes32", "root", 4)]
        public virtual byte[] Root { get; set; }
    }

    public partial class RootFunction : RootFunctionBase { }

    [Function("root", "bytes32")]
    public class RootFunctionBase : FunctionMessage
    {
        [Parameter("address", "network", 1)]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
    }

    public partial class ClaimRewardsEventDTO : ClaimRewardsEventDTOBase { }

    [Event("ClaimRewards")]
    public class ClaimRewardsEventDTOBase : IEventDTO
    {
        [Parameter("address", "recipient", 1, false )]
        public virtual string Recipient { get; set; }
        [Parameter("address", "network", 2, true )]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 3, true )]
        public virtual string Token { get; set; }
        [Parameter("address", "claimer", 4, true )]
        public virtual string Claimer { get; set; }
        [Parameter("uint256", "amount", 5, false )]
        public virtual BigInteger Amount { get; set; }
    }

    public partial class DistributeRewardsEventDTO : DistributeRewardsEventDTOBase { }

    [Event("DistributeRewards")]
    public class DistributeRewardsEventDTOBase : IEventDTO
    {
        [Parameter("address", "network", 1, true )]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2, true )]
        public virtual string Token { get; set; }
        [Parameter("uint256", "amount", 3, false )]
        public virtual BigInteger Amount { get; set; }
        [Parameter("bytes32", "root", 4, false )]
        public virtual byte[] Root { get; set; }
    }

    public partial class InsufficientBalanceError : InsufficientBalanceErrorBase { }
    [Error("InsufficientBalance")]
    public class InsufficientBalanceErrorBase : IErrorDTO
    {
    }

    public partial class InsufficientTotalClaimableError : InsufficientTotalClaimableErrorBase { }
    [Error("InsufficientTotalClaimable")]
    public class InsufficientTotalClaimableErrorBase : IErrorDTO
    {
    }

    public partial class InsufficientTransferError : InsufficientTransferErrorBase { }
    [Error("InsufficientTransfer")]
    public class InsufficientTransferErrorBase : IErrorDTO
    {
    }

    public partial class InvalidProofError : InvalidProofErrorBase { }
    [Error("InvalidProof")]
    public class InvalidProofErrorBase : IErrorDTO
    {
    }

    public partial class NotNetworkMiddlewareError : NotNetworkMiddlewareErrorBase { }
    [Error("NotNetworkMiddleware")]
    public class NotNetworkMiddlewareErrorBase : IErrorDTO
    {
    }

    public partial class RootNotSetError : RootNotSetErrorBase { }
    [Error("RootNotSet")]
    public class RootNotSetErrorBase : IErrorDTO
    {
    }

    public partial class NetworkMiddlewareServiceOutputDTO : NetworkMiddlewareServiceOutputDTOBase { }

    [FunctionOutput]
    public class NetworkMiddlewareServiceOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class BalanceOutputDTO : BalanceOutputDTOBase { }

    [FunctionOutput]
    public class BalanceOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }



    public partial class ClaimedOutputDTO : ClaimedOutputDTOBase { }

    [FunctionOutput]
    public class ClaimedOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }



    public partial class RootOutputDTO : RootOutputDTOBase { }

    [FunctionOutput]
    public class RootOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bytes32", "", 1)]
        public virtual byte[] ReturnValue1 { get; set; }
    }
}
