package fi.symbiotic.relay;

import io.reactivex.Flowable;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Bool;
import org.web3j.abi.datatypes.CustomError;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.StaticStruct;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.RemoteFunctionCall;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.BaseEventResponse;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.Contract;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

/**
 * <p>Auto generated code.
 * <p><strong>Do not modify!</strong>
 * <p>Please use the <a href="https://docs.web3j.io/command_line.html">web3j command line tools</a>,
 * or the org.web3j.codegen.SolidityFunctionWrapperGenerator in the 
 * <a href="https://github.com/LFDT-web3j/web3j/tree/main/codegen">codegen module</a> to update.
 *
 * <p>Generated with web3j version 1.7.0.
 */
@SuppressWarnings("rawtypes")
public class IDefaultStakerRewardsFactory.abi extends Contract {
    public static final String BINARY = "Bin file was not provided";

    public static final String FUNC_CREATE = "create";

    public static final String FUNC_ENTITY = "entity";

    public static final String FUNC_ISENTITY = "isEntity";

    public static final String FUNC_TOTALENTITIES = "totalEntities";

    public static final Event ADDENTITY_EVENT = new Event("AddEntity", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}));
    ;

    public static final CustomError ENTITYNOTEXIST_ERROR = new CustomError("EntityNotExist", 
            Arrays.<TypeReference<?>>asList());
    ;

    @Deprecated
    protected IDefaultStakerRewardsFactory.abi(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected IDefaultStakerRewardsFactory.abi(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected IDefaultStakerRewardsFactory.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected IDefaultStakerRewardsFactory.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteFunctionCall<TransactionReceipt> create(InitParams params) {
        final Function function = new Function(
                FUNC_CREATE, 
                Arrays.<Type>asList(params), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<String> entity(BigInteger index) {
        final Function function = new Function(FUNC_ENTITY, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.generated.Uint256(index)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteFunctionCall<Boolean> isEntity(String account) {
        final Function function = new Function(FUNC_ISENTITY, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, account)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        return executeRemoteCallSingleValueReturn(function, Boolean.class);
    }

    public RemoteFunctionCall<BigInteger> totalEntities() {
        final Function function = new Function(FUNC_TOTALENTITIES, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public static List<AddEntityEventResponse> getAddEntityEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(ADDENTITY_EVENT, transactionReceipt);
        ArrayList<AddEntityEventResponse> responses = new ArrayList<AddEntityEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            AddEntityEventResponse typedResponse = new AddEntityEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.entity = (String) eventValues.getIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static AddEntityEventResponse getAddEntityEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(ADDENTITY_EVENT, log);
        AddEntityEventResponse typedResponse = new AddEntityEventResponse();
        typedResponse.log = log;
        typedResponse.entity = (String) eventValues.getIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<AddEntityEventResponse> addEntityEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getAddEntityEventFromLog(log));
    }

    public Flowable<AddEntityEventResponse> addEntityEventFlowable(DefaultBlockParameter startBlock,
            DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(ADDENTITY_EVENT));
        return addEntityEventFlowable(filter);
    }

    @Deprecated
    public static IDefaultStakerRewardsFactory.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultStakerRewardsFactory.abi(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static IDefaultStakerRewardsFactory.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultStakerRewardsFactory.abi(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static IDefaultStakerRewardsFactory.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return new IDefaultStakerRewardsFactory.abi(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static IDefaultStakerRewardsFactory.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new IDefaultStakerRewardsFactory.abi(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class InitParams extends StaticStruct {
        public String vault;

        public BigInteger adminFee;

        public String defaultAdminRoleHolder;

        public String adminFeeClaimRoleHolder;

        public String adminFeeSetRoleHolder;

        public InitParams(String vault, BigInteger adminFee, String defaultAdminRoleHolder,
                String adminFeeClaimRoleHolder, String adminFeeSetRoleHolder) {
            super(new org.web3j.abi.datatypes.Address(160, vault), 
                    new org.web3j.abi.datatypes.generated.Uint256(adminFee), 
                    new org.web3j.abi.datatypes.Address(160, defaultAdminRoleHolder), 
                    new org.web3j.abi.datatypes.Address(160, adminFeeClaimRoleHolder), 
                    new org.web3j.abi.datatypes.Address(160, adminFeeSetRoleHolder));
            this.vault = vault;
            this.adminFee = adminFee;
            this.defaultAdminRoleHolder = defaultAdminRoleHolder;
            this.adminFeeClaimRoleHolder = adminFeeClaimRoleHolder;
            this.adminFeeSetRoleHolder = adminFeeSetRoleHolder;
        }

        public InitParams(Address vault, Uint256 adminFee, Address defaultAdminRoleHolder,
                Address adminFeeClaimRoleHolder, Address adminFeeSetRoleHolder) {
            super(vault, adminFee, defaultAdminRoleHolder, adminFeeClaimRoleHolder, adminFeeSetRoleHolder);
            this.vault = vault.getValue();
            this.adminFee = adminFee.getValue();
            this.defaultAdminRoleHolder = defaultAdminRoleHolder.getValue();
            this.adminFeeClaimRoleHolder = adminFeeClaimRoleHolder.getValue();
            this.adminFeeSetRoleHolder = adminFeeSetRoleHolder.getValue();
        }
    }

    public static class AddEntityEventResponse extends BaseEventResponse {
        public String entity;
    }
}
