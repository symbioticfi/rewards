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
using Symbiotic.Relay.IDefaultOperatorRewardsFactory.abi.ContractDefinition;

namespace Symbiotic.Relay.IDefaultOperatorRewardsFactory.abi
{
    public partial class IDefaultOperatorRewardsFactory.abiService: IDefaultOperatorRewardsFactory.abiServiceBase
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewardsFactory.abiDeployment iDefaultOperatorRewardsFactory.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultOperatorRewardsFactory.abiDeployment>().SendRequestAndWaitForReceiptAsync(iDefaultOperatorRewardsFactory.abiDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewardsFactory.abiDeployment iDefaultOperatorRewardsFactory.abiDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<IDefaultOperatorRewardsFactory.abiDeployment>().SendRequestAsync(iDefaultOperatorRewardsFactory.abiDeployment);
        }

        public static async Task<IDefaultOperatorRewardsFactory.abiService> DeployContractAndGetServiceAsync(Nethereum.Web3.IWeb3 web3, IDefaultOperatorRewardsFactory.abiDeployment iDefaultOperatorRewardsFactory.abiDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, iDefaultOperatorRewardsFactory.abiDeployment, cancellationTokenSource);
            return new IDefaultOperatorRewardsFactory.abiService(web3, receipt.ContractAddress);
        }

        public IDefaultOperatorRewardsFactory.abiService(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

    }


    public partial class IDefaultOperatorRewardsFactory.abiServiceBase: ContractWeb3ServiceBase
    {

        public IDefaultOperatorRewardsFactory.abiServiceBase(Nethereum.Web3.IWeb3 web3, string contractAddress) : base(web3, contractAddress)
        {
        }

        public virtual Task<string> CreateRequestAsync(CreateFunction createFunction)
        {
             return ContractHandler.SendRequestAsync(createFunction);
        }

        public virtual Task<string> CreateRequestAsync()
        {
             return ContractHandler.SendRequestAsync<CreateFunction>();
        }

        public virtual Task<TransactionReceipt> CreateRequestAndWaitForReceiptAsync(CreateFunction createFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(createFunction, cancellationToken);
        }

        public virtual Task<TransactionReceipt> CreateRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<CreateFunction>(null, cancellationToken);
        }

        public Task<string> EntityQueryAsync(EntityFunction entityFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EntityFunction, string>(entityFunction, blockParameter);
        }

        
        public virtual Task<string> EntityQueryAsync(BigInteger index, BlockParameter blockParameter = null)
        {
            var entityFunction = new EntityFunction();
                entityFunction.Index = index;
            
            return ContractHandler.QueryAsync<EntityFunction, string>(entityFunction, blockParameter);
        }

        public Task<bool> IsEntityQueryAsync(IsEntityFunction isEntityFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsEntityFunction, bool>(isEntityFunction, blockParameter);
        }

        
        public virtual Task<bool> IsEntityQueryAsync(string account, BlockParameter blockParameter = null)
        {
            var isEntityFunction = new IsEntityFunction();
                isEntityFunction.Account = account;
            
            return ContractHandler.QueryAsync<IsEntityFunction, bool>(isEntityFunction, blockParameter);
        }

        public Task<BigInteger> TotalEntitiesQueryAsync(TotalEntitiesFunction totalEntitiesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalEntitiesFunction, BigInteger>(totalEntitiesFunction, blockParameter);
        }

        
        public virtual Task<BigInteger> TotalEntitiesQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalEntitiesFunction, BigInteger>(null, blockParameter);
        }

        public override List<Type> GetAllFunctionTypes()
        {
            return new List<Type>
            {
                typeof(CreateFunction),
                typeof(EntityFunction),
                typeof(IsEntityFunction),
                typeof(TotalEntitiesFunction)
            };
        }

        public override List<Type> GetAllEventTypes()
        {
            return new List<Type>
            {
                typeof(AddEntityEventDTO)
            };
        }

        public override List<Type> GetAllErrorTypes()
        {
            return new List<Type>
            {
                typeof(EntityNotExistError)
            };
        }
    }
}
