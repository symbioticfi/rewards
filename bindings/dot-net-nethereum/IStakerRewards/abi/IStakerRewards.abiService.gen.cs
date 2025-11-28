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
using Symbiotic.Relay.IStakerRewards.abi.ContractDefinition;

namespace Symbiotic.Relay.IStakerRewards.abi
{
    public partial class IStakerRewards.abiService: IStakerRewards.abiServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, IStakerRewards.abiDeployment iStakerRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<IStakerRewards.abiDeployment>().SendRequestAndWaitForReceiptAsync(iStakerRewards.abiDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, IStakerRewards.abiDeployment iStakerRewards.abiDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<IStakerRewards.abiDeployment>().SendRequestAsync(iStakerRewards.abiDeployment);
        }

        public static async Task<IStakerRewards.abiService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, IStakerRewards.abiDeployment iStakerRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, iStakerRewards.abiDeployment, cancellationTokenSource);
            return new IStakerRewards.abiService(web3, receipt.ContractAddress);
        }

        public IStakerRewards.abiService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

    }


    public partial class IStakerRewards.abiServiceBase: ContractWeb3ServiceBase
    {

        public IStakerRewards.abiServiceBase(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
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
                typeof(ClaimRewardsFunction),
                typeof(ClaimableFunction),
                typeof(DistributeRewardsFunction),
                typeof(VersionFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(ClaimRewardsEventDTO),
                typeof(DistributeRewardsEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {

            };
        }
    }
}
