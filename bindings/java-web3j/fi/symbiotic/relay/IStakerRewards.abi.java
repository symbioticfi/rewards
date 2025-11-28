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
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.abi.datatypes.generated.Uint48;
import org.web3j.abi.datatypes.generated.Uint64;
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
public class IStakerRewards.abi extends Contract {
    public static final String BINARY = "Bin file was not provided";

    public static final String FUNC_CLAIMREWARDS = "claimRewards";

    public static final String FUNC_CLAIMABLE = "claimable";

    public static final String FUNC_DISTRIBUTEREWARDS = "distributeRewards";

    public static final String FUNC_VERSION = "version";

    public static final Event CLAIMREWARDS_EVENT = new Event("ClaimRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Address>() {}));
    ;

    public static final Event DISTRIBUTEREWARDS_EVENT = new Event("DistributeRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Uint256>() {}, new TypeReference<Uint48>() {}));
    ;

    @Deprecated
    protected IStakerRewards.abi(String contractAddress, Web3j web3j, Credentials credentials,
            BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected IStakerRewards.abi(String contractAddress, Web3j web3j, Credentials credentials,
            ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected IStakerRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected IStakerRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteFunctionCall<TransactionReceipt> claimRewards(String recipient, String token,
            byte[] data) {
        final Function function = new Function(
                FUNC_CLAIMREWARDS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, recipient), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.DynamicBytes(data)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<BigInteger> claimable(String token, String account, byte[] data) {
        final Function function = new Function(FUNC_CLAIMABLE, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.Address(160, account), 
                new org.web3j.abi.datatypes.DynamicBytes(data)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<TransactionReceipt> distributeRewards(String network, String token,
            BigInteger amount, byte[] data) {
        final Function function = new Function(
                FUNC_DISTRIBUTEREWARDS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.generated.Uint256(amount), 
                new org.web3j.abi.datatypes.DynamicBytes(data)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<BigInteger> version() {
        final Function function = new Function(FUNC_VERSION, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint64>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
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
            typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.recipient = (String) eventValues.getNonIndexedValues().get(1).getValue();
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
        typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        typedResponse.recipient = (String) eventValues.getNonIndexedValues().get(1).getValue();
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
            typedResponse.distributeAmount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.adminFeeAmount = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
            typedResponse.timestamp = (BigInteger) eventValues.getNonIndexedValues().get(2).getValue();
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
        typedResponse.distributeAmount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        typedResponse.adminFeeAmount = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
        typedResponse.timestamp = (BigInteger) eventValues.getNonIndexedValues().get(2).getValue();
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
    public static IStakerRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new IStakerRewards.abi(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static IStakerRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new IStakerRewards.abi(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static IStakerRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return new IStakerRewards.abi(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static IStakerRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new IStakerRewards.abi(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class ClaimRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public String claimer;

        public BigInteger amount;

        public String recipient;
    }

    public static class DistributeRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public BigInteger distributeAmount;

        public BigInteger adminFeeAmount;

        public BigInteger timestamp;
    }
}
