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
import org.web3j.abi.datatypes.CustomError;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Bytes32;
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
public class IDefaultOperatorRewards.abi extends Contract {
    public static final String BINARY = "Bin file was not provided";

    public static final String FUNC_NETWORK_MIDDLEWARE_SERVICE = "NETWORK_MIDDLEWARE_SERVICE";

    public static final String FUNC_BALANCE = "balance";

    public static final String FUNC_CLAIMREWARDS = "claimRewards";

    public static final String FUNC_CLAIMED = "claimed";

    public static final String FUNC_DISTRIBUTEREWARDS = "distributeRewards";

    public static final String FUNC_ROOT = "root";

    public static final Event CLAIMREWARDS_EVENT = new Event("ClaimRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}, new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}));
    ;

    public static final Event DISTRIBUTEREWARDS_EVENT = new Event("DistributeRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Bytes32>() {}));
    ;

    public static final CustomError INSUFFICIENTBALANCE_ERROR = new CustomError("InsufficientBalance", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INSUFFICIENTTOTALCLAIMABLE_ERROR = new CustomError("InsufficientTotalClaimable", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INSUFFICIENTTRANSFER_ERROR = new CustomError("InsufficientTransfer", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INVALIDPROOF_ERROR = new CustomError("InvalidProof", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError NOTNETWORKMIDDLEWARE_ERROR = new CustomError("NotNetworkMiddleware", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError ROOTNOTSET_ERROR = new CustomError("RootNotSet", 
            Arrays.<TypeReference<?>>asList());
    ;

    @Deprecated
    protected IDefaultOperatorRewards.abi(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected IDefaultOperatorRewards.abi(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected IDefaultOperatorRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected IDefaultOperatorRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteFunctionCall<String> NETWORK_MIDDLEWARE_SERVICE() {
        final Function function = new Function(FUNC_NETWORK_MIDDLEWARE_SERVICE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteFunctionCall<BigInteger> balance(String network, String token) {
        final Function function = new Function(FUNC_BALANCE, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<TransactionReceipt> claimRewards(String recipient, String network,
            String token, BigInteger totalClaimable, List<byte[]> proof) {
        final Function function = new Function(
                FUNC_CLAIMREWARDS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, recipient), 
                new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.generated.Uint256(totalClaimable), 
                new org.web3j.abi.datatypes.DynamicArray<org.web3j.abi.datatypes.generated.Bytes32>(
                        org.web3j.abi.datatypes.generated.Bytes32.class,
                        org.web3j.abi.Utils.typeMap(proof, org.web3j.abi.datatypes.generated.Bytes32.class))), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<BigInteger> claimed(String network, String token, String account) {
        final Function function = new Function(FUNC_CLAIMED, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.Address(160, account)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<TransactionReceipt> distributeRewards(String network, String token,
            BigInteger amount, byte[] root) {
        final Function function = new Function(
                FUNC_DISTRIBUTEREWARDS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.generated.Uint256(amount), 
                new org.web3j.abi.datatypes.generated.Bytes32(root)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<byte[]> root(String network, String token) {
        final Function function = new Function(FUNC_ROOT, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
        return executeRemoteCallSingleValueReturn(function, byte[].class);
    }

    public static List<ClaimRewardsEventResponse> getClaimRewardsEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(CLAIMREWARDS_EVENT, transactionReceipt);
        ArrayList<ClaimRewardsEventResponse> responses = new ArrayList<ClaimRewardsEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            ClaimRewardsEventResponse typedResponse = new ClaimRewardsEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.claimer = (String) eventValues.getIndexedValues().get(2).getValue();
            typedResponse.recipient = (String) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static ClaimRewardsEventResponse getClaimRewardsEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(CLAIMREWARDS_EVENT, log);
        ClaimRewardsEventResponse typedResponse = new ClaimRewardsEventResponse();
        typedResponse.log = log;
        typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.claimer = (String) eventValues.getIndexedValues().get(2).getValue();
        typedResponse.recipient = (String) eventValues.getNonIndexedValues().get(0).getValue();
        typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
        return typedResponse;
    }

    public Flowable<ClaimRewardsEventResponse> claimRewardsEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getClaimRewardsEventFromLog(log));
    }

    public Flowable<ClaimRewardsEventResponse> claimRewardsEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(CLAIMREWARDS_EVENT));
        return claimRewardsEventFlowable(filter);
    }

    public static List<DistributeRewardsEventResponse> getDistributeRewardsEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(DISTRIBUTEREWARDS_EVENT, transactionReceipt);
        ArrayList<DistributeRewardsEventResponse> responses = new ArrayList<DistributeRewardsEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            DistributeRewardsEventResponse typedResponse = new DistributeRewardsEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.root = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static DistributeRewardsEventResponse getDistributeRewardsEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(DISTRIBUTEREWARDS_EVENT, log);
        DistributeRewardsEventResponse typedResponse = new DistributeRewardsEventResponse();
        typedResponse.log = log;
        typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        typedResponse.root = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
        return typedResponse;
    }

    public Flowable<DistributeRewardsEventResponse> distributeRewardsEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getDistributeRewardsEventFromLog(log));
    }

    public Flowable<DistributeRewardsEventResponse> distributeRewardsEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(DISTRIBUTEREWARDS_EVENT));
        return distributeRewardsEventFlowable(filter);
    }

    @Deprecated
    public static IDefaultOperatorRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultOperatorRewards.abi(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static IDefaultOperatorRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultOperatorRewards.abi(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static IDefaultOperatorRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return new IDefaultOperatorRewards.abi(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static IDefaultOperatorRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new IDefaultOperatorRewards.abi(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class ClaimRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public String claimer;

        public String recipient;

        public BigInteger amount;
    }

    public static class DistributeRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public BigInteger amount;

        public byte[] root;
    }
}
