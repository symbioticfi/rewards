using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using Symbiotic.Relay.IDefaultStakerRewards.abi.ContractDefinition;

namespace Symbiotic.Relay.IDefaultStakerRewards.abi
{
    public partial class IDefaultStakerRewards.abiService: IDefaultStakerRewards.abiServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, IDefaultStakerRewards.abiDeployment iDefaultStakerRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultStakerRewards.abiDeployment>().SendRequestAndWaitForReceiptAsync(iDefaultStakerRewards.abiDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, IDefaultStakerRewards.abiDeployment iDefaultStakerRewards.abiDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultStakerRewards.abiDeployment>().SendRequestAsync(iDefaultStakerRewards.abiDeployment);
        }

        public static async Task<IDefaultStakerRewards.abiService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, IDefaultStakerRewards.abiDeployment iDefaultStakerRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, iDefaultStakerRewards.abiDeployment, cancellationTokenSource);
            return new IDefaultStakerRewards.abiService(web3, receipt.ContractAddress);
        }

        public IDefaultStakerRewards.abiService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

    }


    public partial class IDefaultStakerRewards.abiServiceBase: ContractWeb3ServiceBase
    {

        public IDefaultStakerRewards.abiServiceBase(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

        public Task<BigInteger> AdminFeeBaseQueryAsync(AdminFeeBaseFunction adminFeeBaseFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeBaseFunction, BigInteger>(adminFeeBaseFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> AdminFeeBaseQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeBaseFunction, BigInteger>(null, blockParameter);
        }

        public Task<byte[]> AdminFeeClaimRoleQueryAsync(AdminFeeClaimRoleFunction adminFeeClaimRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeClaimRoleFunction, byte[]>(adminFeeClaimRoleFunction, blockParameter);
        }

        
        public virtual Task<byte[]> AdminFeeClaimRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeClaimRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> AdminFeeSetRoleQueryAsync(AdminFeeSetRoleFunction adminFeeSetRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeSetRoleFunction, byte[]>(adminFeeSetRoleFunction, blockParameter);
        }

        
        public virtual Task<byte[]> AdminFeeSetRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeSetRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<string> NetworkMiddlewareServiceQueryAsync(NetworkMiddlewareServiceFunction networkMiddlewareServiceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NetworkMiddlewareServiceFunction, string>(networkMiddlewareServiceFunction, blockParameter);
        }

        
        public virtual Task<string> NetworkMiddlewareServiceQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NetworkMiddlewareServiceFunction, string>(null, blockParameter);
        }

        public Task<string> VaultQueryAsync(VaultFunction vaultFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VaultFunction, string>(vaultFunction, blockParameter);
        }

        
        public virtual Task<string> VaultQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VaultFunction, string>(null, blockParameter);
        }

        public Task<string> VaultFactoryQueryAsync(VaultFactoryFunction vaultFactoryFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VaultFactoryFunction, string>(vaultFactoryFunction, blockParameter);
        }

        
        public virtual Task<string> VaultFactoryQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VaultFactoryFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> AdminFeeQueryAsync(AdminFeeFunction adminFeeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeFunction, BigInteger>(adminFeeFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> AdminFeeQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<AdminFeeFunction, BigInteger>(null, blockParameter);
        }

        public virtual Task<string> ClaimAdminFeeRequestAsync(ClaimAdminFeeFunction claimAdminFeeFunction)
        {
             return ContractHandler.SendRequestAsync(claimAdminFeeFunction);
        }

        public virtual Task<TransactionReceipt> ClaimAdminFeeRequestAndWaitForReceiptAsync(ClaimAdminFeeFunction claimAdminFeeFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimAdminFeeFunction, cancellationToken);
        }

        public virtual Task<string> ClaimAdminFeeRequestAsync(string recipient, string token)
        {
            var claimAdminFeeFunction = new ClaimAdminFeeFunction();
                claimAdminFeeFunction.Recipient = recipient;
                claimAdminFeeFunction.Token = token;
            
             return ContractHandler.SendRequestAsync(claimAdminFeeFunction);
        }

        public virtual Task<TransactionReceipt> ClaimAdminFeeRequestAndWaitForReceiptAsync(string recipient, string token, CancellationTokenSource cancellationToken = null)
        {
            var claimAdminFeeFunction = new ClaimAdminFeeFunction();
                claimAdminFeeFunction.Recipient = recipient;
                claimAdminFeeFunction.Token = token;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimAdminFeeFunction, cancellationToken);
        }

        public virtual Task<string> ClaimRewardsRequestAsync(ClaimRewardsFunction claimRewardsFunction)
        {
             return ContractHandler.SendRequestAsync(claimRewardsFunction);
        }

        public virtual Task<TransactionReceipt> ClaimRewardsRequestAndWaitForReceiptAsync(ClaimRewardsFunction claimRewardsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardsFunction, cancellationToken);
        }

        public virtual Task<string> ClaimRewardsRequestAsync(string recipient, string token, byte[] data)
        {
            var claimRewardsFunction = new ClaimRewardsFunction();
                claimRewardsFunction.Recipient = recipient;
                claimRewardsFunction.Token = token;
                claimRewardsFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(claimRewardsFunction);
        }

        public virtual Task<TransactionReceipt> ClaimRewardsRequestAndWaitForReceiptAsync(string recipient, string token, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var claimRewardsFunction = new ClaimRewardsFunction();
                claimRewardsFunction.Recipient = recipient;
                claimRewardsFunction.Token = token;
                claimRewardsFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardsFunction, cancellationToken);
        }

        public Task<BigInteger> ClaimableQueryAsync(ClaimableFunction claimableFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClaimableFunction, BigInteger>(claimableFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> ClaimableQueryAsync(string token, string account, byte[] data, BlockParameter blockParameter = null)
        {
            var claimableFunction = new ClaimableFunction();
                claimableFunction.Token = token;
                claimableFunction.Account = account;
                claimableFunction.Data = data;
            
            return ContractHandler.QueryAsync<ClaimableFunction, BigInteger>(claimableFunction, blockParameter);
        }

        public Task<BigInteger> ClaimableAdminFeeQueryAsync(ClaimableAdminFeeFunction claimableAdminFeeFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClaimableAdminFeeFunction, BigInteger>(claimableAdminFeeFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> ClaimableAdminFeeQueryAsync(string token, BlockParameter blockParameter = null)
        {
            var claimableAdminFeeFunction = new ClaimableAdminFeeFunction();
                claimableAdminFeeFunction.Token = token;
            
            return ContractHandler.QueryAsync<ClaimableAdminFeeFunction, BigInteger>(claimableAdminFeeFunction, blockParameter);
        }

        public virtual Task<string> DistributeRewardsRequestAsync(DistributeRewardsFunction distributeRewardsFunction)
        {
             return ContractHandler.SendRequestAsync(distributeRewardsFunction);
        }

        public virtual Task<TransactionReceipt> DistributeRewardsRequestAndWaitForReceiptAsync(DistributeRewardsFunction distributeRewardsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(distributeRewardsFunction, cancellationToken);
        }

        public virtual Task<string> DistributeRewardsRequestAsync(string network, string token, BigInteger amount, byte[] data)
        {
            var distributeRewardsFunction = new DistributeRewardsFunction();
                distributeRewardsFunction.Network = network;
                distributeRewardsFunction.Token = token;
                distributeRewardsFunction.Amount = amount;
                distributeRewardsFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(distributeRewardsFunction);
        }

        public virtual Task<TransactionReceipt> DistributeRewardsRequestAndWaitForReceiptAsync(string network, string token, BigInteger amount, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var distributeRewardsFunction = new DistributeRewardsFunction();
                distributeRewardsFunction.Network = network;
                distributeRewardsFunction.Token = token;
                distributeRewardsFunction.Amount = amount;
                distributeRewardsFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(distributeRewardsFunction, cancellationToken);
        }

        public Task<BigInteger> LastUnclaimedRewardQueryAsync(LastUnclaimedRewardFunction lastUnclaimedRewardFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<LastUnclaimedRewardFunction, BigInteger>(lastUnclaimedRewardFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> LastUnclaimedRewardQueryAsync(string account, string token, string network, BlockParameter blockParameter = null)
        {
            var lastUnclaimedRewardFunction = new LastUnclaimedRewardFunction();
                lastUnclaimedRewardFunction.Account = account;
                lastUnclaimedRewardFunction.Token = token;
                lastUnclaimedRewardFunction.Network = network;
            
            return ContractHandler.QueryAsync<LastUnclaimedRewardFunction, BigInteger>(lastUnclaimedRewardFunction, blockParameter);
        }

        public virtual Task<RewardsOutputDTO> RewardsQueryAsync(RewardsFunction rewardsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryDeserializingToObjectAsync<RewardsFunction, RewardsOutputDTO>(rewardsFunction, blockParameter);
        }

        public virtual Task<RewardsOutputDTO> RewardsQueryAsync(string token, string network, BigInteger rewardIndex, BlockParameter blockParameter = null)
        {
            var rewardsFunction = new RewardsFunction();
                rewardsFunction.Token = token;
                rewardsFunction.Network = network;
                rewardsFunction.RewardIndex = rewardIndex;
            
            return ContractHandler.QueryDeserializingToObjectAsync<RewardsFunction, RewardsOutputDTO>(rewardsFunction, blockParameter);
        }

        public Task<BigInteger> RewardsLengthQueryAsync(RewardsLengthFunction rewardsLengthFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RewardsLengthFunction, BigInteger>(rewardsLengthFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> RewardsLengthQueryAsync(string token, string network, BlockParameter blockParameter = null)
        {
            var rewardsLengthFunction = new RewardsLengthFunction();
                rewardsLengthFunction.Token = token;
                rewardsLengthFunction.Network = network;
            
            return ContractHandler.QueryAsync<RewardsLengthFunction, BigInteger>(rewardsLengthFunction, blockParameter);
        }

        public virtual Task<string> SetAdminFeeRequestAsync(SetAdminFeeFunction setAdminFeeFunction)
        {
             return ContractHandler.SendRequestAsync(setAdminFeeFunction);
        }

        public virtual Task<TransactionReceipt> SetAdminFeeRequestAndWaitForReceiptAsync(SetAdminFeeFunction setAdminFeeFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setAdminFeeFunction, cancellationToken);
        }

        public virtual Task<string> SetAdminFeeRequestAsync(BigInteger adminFee)
        {
            var setAdminFeeFunction = new SetAdminFeeFunction();
                setAdminFeeFunction.AdminFee = adminFee;
            
             return ContractHandler.SendRequestAsync(setAdminFeeFunction);
        }

        public virtual Task<TransactionReceipt> SetAdminFeeRequestAndWaitForReceiptAsync(BigInteger adminFee, CancellationTokenSource cancellationToken = null)
        {
            var setAdminFeeFunction = new SetAdminFeeFunction();
                setAdminFeeFunction.AdminFee = adminFee;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setAdminFeeFunction, cancellationToken);
        }

        public Task<ulong> VersionQueryAsync(VersionFunction versionFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VersionFunction, ulong>(versionFunction, blockParameter);
        }

        
        public virtual Task<ulong> VersionQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VersionFunction, ulong>(null, blockParameter);
        }

        public override List<Type> GetAllFunctionTypes()
        {
            return new List<Type>
            {
                typeof(AdminFeeBaseFunction),
                typeof(AdminFeeClaimRoleFunction),
                typeof(AdminFeeSetRoleFunction),
                typeof(NetworkMiddlewareServiceFunction),
                typeof(VaultFunction),
                typeof(VaultFactoryFunction),
                typeof(AdminFeeFunction),
                typeof(ClaimAdminFeeFunction),
                typeof(ClaimRewardsFunction),
                typeof(ClaimableFunction),
                typeof(ClaimableAdminFeeFunction),
                typeof(DistributeRewardsFunction),
                typeof(LastUnclaimedRewardFunction),
                typeof(RewardsFunction),
                typeof(RewardsLengthFunction),
                typeof(SetAdminFeeFunction),
                typeof(VersionFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(ClaimAdminFeeEventDTO),
                typeof(ClaimRewardsEventDTO),
                typeof(ClaimRewardsExtraEventDTO),
                typeof(DistributeRewardsEventDTO),
                typeof(InitVaultEventDTO),
                typeof(SetAdminFeeEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(AlreadySetError),
                typeof(HighAdminFeeError),
                typeof(InsufficientAdminFeeError),
                typeof(InsufficientRewardError),
                typeof(InvalidAdminFeeError),
                typeof(InvalidHintsLengthError),
                typeof(InvalidRecipientError),
                typeof(InvalidRewardTimestampError),
                typeof(MissingRolesError),
                typeof(NoRewardsToClaimError),
                typeof(NotNetworkError),
                typeof(NotNetworkMiddlewareError),
                typeof(NotVaultError)
            };
        }
    }
}
