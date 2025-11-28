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
using Symbiotic.Relay.IDefaultOperatorRewards.abi.ContractDefinition;

namespace Symbiotic.Relay.IDefaultOperatorRewards.abi
{
    public partial class IDefaultOperatorRewards.abiService: IDefaultOperatorRewards.abiServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewards.abiDeployment iDefaultOperatorRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultOperatorRewards.abiDeployment>().SendRequestAndWaitForReceiptAsync(iDefaultOperatorRewards.abiDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewards.abiDeployment iDefaultOperatorRewards.abiDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultOperatorRewards.abiDeployment>().SendRequestAsync(iDefaultOperatorRewards.abiDeployment);
        }

        public static async Task<IDefaultOperatorRewards.abiService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewards.abiDeployment iDefaultOperatorRewards.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, iDefaultOperatorRewards.abiDeployment, cancellationTokenSource);
            return new IDefaultOperatorRewards.abiService(web3, receipt.ContractAddress);
        }

        public IDefaultOperatorRewards.abiService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

    }


    public partial class IDefaultOperatorRewards.abiServiceBase: ContractWeb3ServiceBase
    {

        public IDefaultOperatorRewards.abiServiceBase(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

        public Task<string> NetworkMiddlewareServiceQueryAsync(NetworkMiddlewareServiceFunction networkMiddlewareServiceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NetworkMiddlewareServiceFunction, string>(networkMiddlewareServiceFunction, blockParameter);
        }

        
        public virtual Task<string> NetworkMiddlewareServiceQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NetworkMiddlewareServiceFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> BalanceQueryAsync(BalanceFunction balanceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceFunction, BigInteger>(balanceFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> BalanceQueryAsync(string network, string token, BlockParameter blockParameter = null)
        {
            var balanceFunction = new BalanceFunction();
                balanceFunction.Network = network;
                balanceFunction.Token = token;
            
            return ContractHandler.QueryAsync<BalanceFunction, BigInteger>(balanceFunction, blockParameter);
        }

        public virtual Task<string> ClaimRewardsRequestAsync(ClaimRewardsFunction claimRewardsFunction)
        {
             return ContractHandler.SendRequestAsync(claimRewardsFunction);
        }

        public virtual Task<TransactionReceipt> ClaimRewardsRequestAndWaitForReceiptAsync(ClaimRewardsFunction claimRewardsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardsFunction, cancellationToken);
        }

        public virtual Task<string> ClaimRewardsRequestAsync(string recipient, string network, string token, BigInteger totalClaimable, List<byte[]> proof)
        {
            var claimRewardsFunction = new ClaimRewardsFunction();
                claimRewardsFunction.Recipient = recipient;
                claimRewardsFunction.Network = network;
                claimRewardsFunction.Token = token;
                claimRewardsFunction.TotalClaimable = totalClaimable;
                claimRewardsFunction.Proof = proof;
            
             return ContractHandler.SendRequestAsync(claimRewardsFunction);
        }

        public virtual Task<TransactionReceipt> ClaimRewardsRequestAndWaitForReceiptAsync(string recipient, string network, string token, BigInteger totalClaimable, List<byte[]> proof, CancellationTokenSource cancellationToken = null)
        {
            var claimRewardsFunction = new ClaimRewardsFunction();
                claimRewardsFunction.Recipient = recipient;
                claimRewardsFunction.Network = network;
                claimRewardsFunction.Token = token;
                claimRewardsFunction.TotalClaimable = totalClaimable;
                claimRewardsFunction.Proof = proof;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(claimRewardsFunction, cancellationToken);
        }

        public Task<BigInteger> ClaimedQueryAsync(ClaimedFunction claimedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ClaimedFunction, BigInteger>(claimedFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> ClaimedQueryAsync(string network, string token, string account, BlockParameter blockParameter = null)
        {
            var claimedFunction = new ClaimedFunction();
                claimedFunction.Network = network;
                claimedFunction.Token = token;
                claimedFunction.Account = account;
            
            return ContractHandler.QueryAsync<ClaimedFunction, BigInteger>(claimedFunction, blockParameter);
        }

        public virtual Task<string> DistributeRewardsRequestAsync(DistributeRewardsFunction distributeRewardsFunction)
        {
             return ContractHandler.SendRequestAsync(distributeRewardsFunction);
        }

        public virtual Task<TransactionReceipt> DistributeRewardsRequestAndWaitForReceiptAsync(DistributeRewardsFunction distributeRewardsFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(distributeRewardsFunction, cancellationToken);
        }

        public virtual Task<string> DistributeRewardsRequestAsync(string network, string token, BigInteger amount, byte[] root)
        {
            var distributeRewardsFunction = new DistributeRewardsFunction();
                distributeRewardsFunction.Network = network;
                distributeRewardsFunction.Token = token;
                distributeRewardsFunction.Amount = amount;
                distributeRewardsFunction.Root = root;
            
             return ContractHandler.SendRequestAsync(distributeRewardsFunction);
        }

        public virtual Task<TransactionReceipt> DistributeRewardsRequestAndWaitForReceiptAsync(string network, string token, BigInteger amount, byte[] root, CancellationTokenSource cancellationToken = null)
        {
            var distributeRewardsFunction = new DistributeRewardsFunction();
                distributeRewardsFunction.Network = network;
                distributeRewardsFunction.Token = token;
                distributeRewardsFunction.Amount = amount;
                distributeRewardsFunction.Root = root;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(distributeRewardsFunction, cancellationToken);
        }

        public Task<byte[]> RootQueryAsync(RootFunction rootFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<RootFunction, byte[]>(rootFunction, blockParameter);
        }

        
        public virtual Task<byte[]> RootQueryAsync(string network, string token, BlockParameter blockParameter = null)
        {
            var rootFunction = new RootFunction();
                rootFunction.Network = network;
                rootFunction.Token = token;
            
            return ContractHandler.QueryAsync<RootFunction, byte[]>(rootFunction, blockParameter);
        }

        public override List<Type> GetAllFunctionTypes()
        {
            return new List<Type>
            {
                typeof(NetworkMiddlewareServiceFunction),
                typeof(BalanceFunction),
                typeof(ClaimRewardsFunction),
                typeof(ClaimedFunction),
                typeof(DistributeRewardsFunction),
                typeof(RootFunction)
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
                typeof(InsufficientBalanceError),
                typeof(InsufficientTotalClaimableError),
                typeof(InsufficientTransferError),
                typeof(InvalidProofError),
                typeof(NotNetworkMiddlewareError),
                typeof(RootNotSetError)
            };
        }
    }
}
