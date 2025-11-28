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

namespace Symbiotic.Relay.IDefaultStakerRewards.abi.ContractDefinition
{


    public partial class IDefaultStakerRewards.abiDeployment : IDefaultStakerRewards.abiDeploymentBase
    {
        public IDefaultStakerRewards.abiDeployment() : base(BYTECODE) { }
        public IDefaultStakerRewards.abiDeployment(string byteCode) : base(byteCode) { }
    }

    public class IDefaultStakerRewards.abiDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "";
        public IDefaultStakerRewards.abiDeploymentBase() : base(BYTECODE) { }
        public IDefaultStakerRewards.abiDeploymentBase(string byteCode) : base(byteCode) { }

    }

    public partial class AdminFeeBaseFunction : AdminFeeBaseFunctionBase { }

    [Function("ADMIN_FEE_BASE", "uint256")]
    public class AdminFeeBaseFunctionBase : FunctionMessage
    {

    }

    public partial class AdminFeeClaimRoleFunction : AdminFeeClaimRoleFunctionBase { }

    [Function("ADMIN_FEE_CLAIM_ROLE", "bytes32")]
    public class AdminFeeClaimRoleFunctionBase : FunctionMessage
    {

    }

    public partial class AdminFeeSetRoleFunction : AdminFeeSetRoleFunctionBase { }

    [Function("ADMIN_FEE_SET_ROLE", "bytes32")]
    public class AdminFeeSetRoleFunctionBase : FunctionMessage
    {

    }

    public partial class NetworkMiddlewareServiceFunction : NetworkMiddlewareServiceFunctionBase { }

    [Function("NETWORK_MIDDLEWARE_SERVICE", "address")]
    public class NetworkMiddlewareServiceFunctionBase : FunctionMessage
    {

    }

    public partial class VaultFunction : VaultFunctionBase { }

    [Function("VAULT", "address")]
    public class VaultFunctionBase : FunctionMessage
    {

    }

    public partial class VaultFactoryFunction : VaultFactoryFunctionBase { }

    [Function("VAULT_FACTORY", "address")]
    public class VaultFactoryFunctionBase : FunctionMessage
    {

    }

    public partial class AdminFeeFunction : AdminFeeFunctionBase { }

    [Function("adminFee", "uint256")]
    public class AdminFeeFunctionBase : FunctionMessage
    {

    }

    public partial class ClaimAdminFeeFunction : ClaimAdminFeeFunctionBase { }

    [Function("claimAdminFee")]
    public class ClaimAdminFeeFunctionBase : FunctionMessage
    {
        [Parameter("address", "recipient", 1)]
        public virtual string Recipient { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
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

    public partial class ClaimableAdminFeeFunction : ClaimableAdminFeeFunctionBase { }

    [Function("claimableAdminFee", "uint256")]
    public class ClaimableAdminFeeFunctionBase : FunctionMessage
    {
        [Parameter("address", "token", 1)]
        public virtual string Token { get; set; }
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

    public partial class LastUnclaimedRewardFunction : LastUnclaimedRewardFunctionBase { }

    [Function("lastUnclaimedReward", "uint256")]
    public class LastUnclaimedRewardFunctionBase : FunctionMessage
    {
        [Parameter("address", "account", 1)]
        public virtual string Account { get; set; }
        [Parameter("address", "token", 2)]
        public virtual string Token { get; set; }
        [Parameter("address", "network", 3)]
        public virtual string Network { get; set; }
    }

    public partial class RewardsFunction : RewardsFunctionBase { }

    [Function("rewards", typeof(RewardsOutputDTO))]
    public class RewardsFunctionBase : FunctionMessage
    {
        [Parameter("address", "token", 1)]
        public virtual string Token { get; set; }
        [Parameter("address", "network", 2)]
        public virtual string Network { get; set; }
        [Parameter("uint256", "rewardIndex", 3)]
        public virtual BigInteger RewardIndex { get; set; }
    }

    public partial class RewardsLengthFunction : RewardsLengthFunctionBase { }

    [Function("rewardsLength", "uint256")]
    public class RewardsLengthFunctionBase : FunctionMessage
    {
        [Parameter("address", "token", 1)]
        public virtual string Token { get; set; }
        [Parameter("address", "network", 2)]
        public virtual string Network { get; set; }
    }

    public partial class SetAdminFeeFunction : SetAdminFeeFunctionBase { }

    [Function("setAdminFee")]
    public class SetAdminFeeFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "adminFee", 1)]
        public virtual BigInteger AdminFee { get; set; }
    }

    public partial class VersionFunction : VersionFunctionBase { }

    [Function("version", "uint64")]
    public class VersionFunctionBase : FunctionMessage
    {

    }

    public partial class ClaimAdminFeeEventDTO : ClaimAdminFeeEventDTOBase { }

    [Event("ClaimAdminFee")]
    public class ClaimAdminFeeEventDTOBase : IEventDTO
    {
        [Parameter("address", "recipient", 1, true )]
        public virtual string Recipient { get; set; }
        [Parameter("uint256", "amount", 2, false )]
        public virtual BigInteger Amount { get; set; }
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

    public partial class ClaimRewardsExtraEventDTO : ClaimRewardsExtraEventDTOBase { }

    [Event("ClaimRewardsExtra")]
    public class ClaimRewardsExtraEventDTOBase : IEventDTO
    {
        [Parameter("address", "network", 1, true )]
        public virtual string Network { get; set; }
        [Parameter("address", "token", 2, true )]
        public virtual string Token { get; set; }
        [Parameter("address", "claimer", 3, true )]
        public virtual string Claimer { get; set; }
        [Parameter("uint256", "firstClaimedRewardIndex", 4, false )]
        public virtual BigInteger FirstClaimedRewardIndex { get; set; }
        [Parameter("uint256", "rewardsClaimed", 5, false )]
        public virtual BigInteger RewardsClaimed { get; set; }
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

    public partial class InitVaultEventDTO : InitVaultEventDTOBase { }

    [Event("InitVault")]
    public class InitVaultEventDTOBase : IEventDTO
    {
        [Parameter("address", "vault", 1, false )]
        public virtual string Vault { get; set; }
    }

    public partial class SetAdminFeeEventDTO : SetAdminFeeEventDTOBase { }

    [Event("SetAdminFee")]
    public class SetAdminFeeEventDTOBase : IEventDTO
    {
        [Parameter("uint256", "adminFee", 1, false )]
        public virtual BigInteger AdminFee { get; set; }
    }

    public partial class AlreadySetError : AlreadySetErrorBase { }
    [Error("AlreadySet")]
    public class AlreadySetErrorBase : IErrorDTO
    {
    }

    public partial class HighAdminFeeError : HighAdminFeeErrorBase { }
    [Error("HighAdminFee")]
    public class HighAdminFeeErrorBase : IErrorDTO
    {
    }

    public partial class InsufficientAdminFeeError : InsufficientAdminFeeErrorBase { }
    [Error("InsufficientAdminFee")]
    public class InsufficientAdminFeeErrorBase : IErrorDTO
    {
    }

    public partial class InsufficientRewardError : InsufficientRewardErrorBase { }
    [Error("InsufficientReward")]
    public class InsufficientRewardErrorBase : IErrorDTO
    {
    }

    public partial class InvalidAdminFeeError : InvalidAdminFeeErrorBase { }
    [Error("InvalidAdminFee")]
    public class InvalidAdminFeeErrorBase : IErrorDTO
    {
    }

    public partial class InvalidHintsLengthError : InvalidHintsLengthErrorBase { }
    [Error("InvalidHintsLength")]
    public class InvalidHintsLengthErrorBase : IErrorDTO
    {
    }

    public partial class InvalidRecipientError : InvalidRecipientErrorBase { }
    [Error("InvalidRecipient")]
    public class InvalidRecipientErrorBase : IErrorDTO
    {
    }

    public partial class InvalidRewardTimestampError : InvalidRewardTimestampErrorBase { }
    [Error("InvalidRewardTimestamp")]
    public class InvalidRewardTimestampErrorBase : IErrorDTO
    {
    }

    public partial class MissingRolesError : MissingRolesErrorBase { }
    [Error("MissingRoles")]
    public class MissingRolesErrorBase : IErrorDTO
    {
    }

    public partial class NoRewardsToClaimError : NoRewardsToClaimErrorBase { }
    [Error("NoRewardsToClaim")]
    public class NoRewardsToClaimErrorBase : IErrorDTO
    {
    }

    public partial class NotNetworkError : NotNetworkErrorBase { }
    [Error("NotNetwork")]
    public class NotNetworkErrorBase : IErrorDTO
    {
    }

    public partial class NotNetworkMiddlewareError : NotNetworkMiddlewareErrorBase { }
    [Error("NotNetworkMiddleware")]
    public class NotNetworkMiddlewareErrorBase : IErrorDTO
    {
    }

    public partial class NotVaultError : NotVaultErrorBase { }
    [Error("NotVault")]
    public class NotVaultErrorBase : IErrorDTO
    {
    }

    public partial class AdminFeeBaseOutputDTO : AdminFeeBaseOutputDTOBase { }

    [FunctionOutput]
    public class AdminFeeBaseOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class AdminFeeClaimRoleOutputDTO : AdminFeeClaimRoleOutputDTOBase { }

    [FunctionOutput]
    public class AdminFeeClaimRoleOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bytes32", "", 1)]
        public virtual byte[] ReturnValue1 { get; set; }
    }

    public partial class AdminFeeSetRoleOutputDTO : AdminFeeSetRoleOutputDTOBase { }

    [FunctionOutput]
    public class AdminFeeSetRoleOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bytes32", "", 1)]
        public virtual byte[] ReturnValue1 { get; set; }
    }

    public partial class NetworkMiddlewareServiceOutputDTO : NetworkMiddlewareServiceOutputDTOBase { }

    [FunctionOutput]
    public class NetworkMiddlewareServiceOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class VaultOutputDTO : VaultOutputDTOBase { }

    [FunctionOutput]
    public class VaultOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class VaultFactoryOutputDTO : VaultFactoryOutputDTOBase { }

    [FunctionOutput]
    public class VaultFactoryOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class AdminFeeOutputDTO : AdminFeeOutputDTOBase { }

    [FunctionOutput]
    public class AdminFeeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }





    public partial class ClaimableOutputDTO : ClaimableOutputDTOBase { }

    [FunctionOutput]
    public class ClaimableOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class ClaimableAdminFeeOutputDTO : ClaimableAdminFeeOutputDTOBase { }

    [FunctionOutput]
    public class ClaimableAdminFeeOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }



    public partial class LastUnclaimedRewardOutputDTO : LastUnclaimedRewardOutputDTOBase { }

    [FunctionOutput]
    public class LastUnclaimedRewardOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }

    public partial class RewardsOutputDTO : RewardsOutputDTOBase { }

    [FunctionOutput]
    public class RewardsOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "amount", 1)]
        public virtual BigInteger Amount { get; set; }
        [Parameter("uint48", "timestamp", 2)]
        public virtual ulong Timestamp { get; set; }
    }

    public partial class RewardsLengthOutputDTO : RewardsLengthOutputDTOBase { }

    [FunctionOutput]
    public class RewardsLengthOutputDTOBase : IFunctionOutputDTO 
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
