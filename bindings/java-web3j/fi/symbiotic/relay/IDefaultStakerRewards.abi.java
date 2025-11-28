package fi.symbiotic.relay;

import io.reactivex.Flowable;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.CustomError;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Bytes32;
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
import org.web3j.tuples.generated.Tuple2;
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
public class IDefaultStakerRewards.abi extends Contract {
    public static final String BINARY = "Bin file was not provided";

    public static final String FUNC_ADMIN_FEE_BASE = "ADMIN_FEE_BASE";

    public static final String FUNC_ADMIN_FEE_CLAIM_ROLE = "ADMIN_FEE_CLAIM_ROLE";

    public static final String FUNC_ADMIN_FEE_SET_ROLE = "ADMIN_FEE_SET_ROLE";

    public static final String FUNC_NETWORK_MIDDLEWARE_SERVICE = "NETWORK_MIDDLEWARE_SERVICE";

    public static final String FUNC_VAULT = "VAULT";

    public static final String FUNC_VAULT_FACTORY = "VAULT_FACTORY";

    public static final String FUNC_ADMINFEE = "adminFee";

    public static final String FUNC_CLAIMADMINFEE = "claimAdminFee";

    public static final String FUNC_CLAIMREWARDS = "claimRewards";

    public static final String FUNC_CLAIMABLE = "claimable";

    public static final String FUNC_CLAIMABLEADMINFEE = "claimableAdminFee";

    public static final String FUNC_DISTRIBUTEREWARDS = "distributeRewards";

    public static final String FUNC_LASTUNCLAIMEDREWARD = "lastUnclaimedReward";

    public static final String FUNC_REWARDS = "rewards";

    public static final String FUNC_REWARDSLENGTH = "rewardsLength";

    public static final String FUNC_SETADMINFEE = "setAdminFee";

    public static final String FUNC_VERSION = "version";

    public static final Event CLAIMADMINFEE_EVENT = new Event("ClaimAdminFee", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}));
    ;

    public static final Event CLAIMREWARDS_EVENT = new Event("ClaimRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Address>() {}));
    ;

    public static final Event CLAIMREWARDSEXTRA_EVENT = new Event("ClaimRewardsExtra", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Uint256>() {}));
    ;

    public static final Event DISTRIBUTEREWARDS_EVENT = new Event("DistributeRewards", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<Uint256>() {}, new TypeReference<Uint48>() {}));
    ;

    public static final Event INITVAULT_EVENT = new Event("InitVault", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
    ;

    public static final Event SETADMINFEE_EVENT = new Event("SetAdminFee", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
    ;

    public static final CustomError ALREADYSET_ERROR = new CustomError("AlreadySet", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError HIGHADMINFEE_ERROR = new CustomError("HighAdminFee", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INSUFFICIENTADMINFEE_ERROR = new CustomError("InsufficientAdminFee", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INSUFFICIENTREWARD_ERROR = new CustomError("InsufficientReward", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INVALIDADMINFEE_ERROR = new CustomError("InvalidAdminFee", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INVALIDHINTSLENGTH_ERROR = new CustomError("InvalidHintsLength", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INVALIDRECIPIENT_ERROR = new CustomError("InvalidRecipient", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError INVALIDREWARDTIMESTAMP_ERROR = new CustomError("InvalidRewardTimestamp", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError MISSINGROLES_ERROR = new CustomError("MissingRoles", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError NOREWARDSTOCLAIM_ERROR = new CustomError("NoRewardsToClaim", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError NOTNETWORK_ERROR = new CustomError("NotNetwork", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError NOTNETWORKMIDDLEWARE_ERROR = new CustomError("NotNetworkMiddleware", 
            Arrays.<TypeReference<?>>asList());
    ;

    public static final CustomError NOTVAULT_ERROR = new CustomError("NotVault", 
            Arrays.<TypeReference<?>>asList());
    ;

    @Deprecated
    protected IDefaultStakerRewards.abi(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected IDefaultStakerRewards.abi(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected IDefaultStakerRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected IDefaultStakerRewards.abi(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteFunctionCall<BigInteger> ADMIN_FEE_BASE() {
        final Function function = new Function(FUNC_ADMIN_FEE_BASE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<byte[]> ADMIN_FEE_CLAIM_ROLE() {
        final Function function = new Function(FUNC_ADMIN_FEE_CLAIM_ROLE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
        return executeRemoteCallSingleValueReturn(function, byte[].class);
    }

    public RemoteFunctionCall<byte[]> ADMIN_FEE_SET_ROLE() {
        final Function function = new Function(FUNC_ADMIN_FEE_SET_ROLE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
        return executeRemoteCallSingleValueReturn(function, byte[].class);
    }

    public RemoteFunctionCall<String> NETWORK_MIDDLEWARE_SERVICE() {
        final Function function = new Function(FUNC_NETWORK_MIDDLEWARE_SERVICE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteFunctionCall<String> VAULT() {
        final Function function = new Function(FUNC_VAULT, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteFunctionCall<String> VAULT_FACTORY() {
        final Function function = new Function(FUNC_VAULT_FACTORY, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteFunctionCall<BigInteger> adminFee() {
        final Function function = new Function(FUNC_ADMINFEE, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<TransactionReceipt> claimAdminFee(String recipient, String token) {
        final Function function = new Function(
                FUNC_CLAIMADMINFEE, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, recipient), 
                new org.web3j.abi.datatypes.Address(160, token)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
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

    public RemoteFunctionCall<BigInteger> claimableAdminFee(String token) {
        final Function function = new Function(FUNC_CLAIMABLEADMINFEE, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, token)), 
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

    public RemoteFunctionCall<BigInteger> lastUnclaimedReward(String account, String token,
            String network) {
        final Function function = new Function(FUNC_LASTUNCLAIMEDREWARD, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, account), 
                new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.Address(160, network)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<Tuple2<BigInteger, BigInteger>> rewards(String token, String network,
            BigInteger rewardIndex) {
        final Function function = new Function(FUNC_REWARDS, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.Address(160, network), 
                new org.web3j.abi.datatypes.generated.Uint256(rewardIndex)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}, new TypeReference<Uint48>() {}));
        return new RemoteFunctionCall<Tuple2<BigInteger, BigInteger>>(function,
                new Callable<Tuple2<BigInteger, BigInteger>>() {
                    @Override
                    public Tuple2<BigInteger, BigInteger> call() throws Exception {
                        List<Type> results = executeCallMultipleValueReturn(function);
                        return new Tuple2<BigInteger, BigInteger>(
                                (BigInteger) results.get(0).getValue(), 
                                (BigInteger) results.get(1).getValue());
                    }
                });
    }

    public RemoteFunctionCall<BigInteger> rewardsLength(String token, String network) {
        final Function function = new Function(FUNC_REWARDSLENGTH, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.Address(160, token), 
                new org.web3j.abi.datatypes.Address(160, network)), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteFunctionCall<TransactionReceipt> setAdminFee(BigInteger adminFee) {
        final Function function = new Function(
                FUNC_SETADMINFEE, 
                Arrays.<Type>asList(new org.web3j.abi.datatypes.generated.Uint256(adminFee)), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteFunctionCall<BigInteger> version() {
        final Function function = new Function(FUNC_VERSION, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint64>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public static List<ClaimAdminFeeEventResponse> getClaimAdminFeeEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(CLAIMADMINFEE_EVENT, transactionReceipt);
        ArrayList<ClaimAdminFeeEventResponse> responses = new ArrayList<ClaimAdminFeeEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            ClaimAdminFeeEventResponse typedResponse = new ClaimAdminFeeEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.recipient = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static ClaimAdminFeeEventResponse getClaimAdminFeeEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(CLAIMADMINFEE_EVENT, log);
        ClaimAdminFeeEventResponse typedResponse = new ClaimAdminFeeEventResponse();
        typedResponse.log = log;
        typedResponse.recipient = (String) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.amount = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<ClaimAdminFeeEventResponse> claimAdminFeeEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getClaimAdminFeeEventFromLog(log));
    }

    public Flowable<ClaimAdminFeeEventResponse> claimAdminFeeEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(CLAIMADMINFEE_EVENT));
        return claimAdminFeeEventFlowable(filter);
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

    public static List<ClaimRewardsExtraEventResponse> getClaimRewardsExtraEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(CLAIMREWARDSEXTRA_EVENT, transactionReceipt);
        ArrayList<ClaimRewardsExtraEventResponse> responses = new ArrayList<ClaimRewardsExtraEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            ClaimRewardsExtraEventResponse typedResponse = new ClaimRewardsExtraEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.claimer = (String) eventValues.getIndexedValues().get(2).getValue();
            typedResponse.firstClaimedRewardIndex = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.rewardsClaimed = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static ClaimRewardsExtraEventResponse getClaimRewardsExtraEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(CLAIMREWARDSEXTRA_EVENT, log);
        ClaimRewardsExtraEventResponse typedResponse = new ClaimRewardsExtraEventResponse();
        typedResponse.log = log;
        typedResponse.network = (String) eventValues.getIndexedValues().get(0).getValue();
        typedResponse.token = (String) eventValues.getIndexedValues().get(1).getValue();
        typedResponse.claimer = (String) eventValues.getIndexedValues().get(2).getValue();
        typedResponse.firstClaimedRewardIndex = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        typedResponse.rewardsClaimed = (BigInteger) eventValues.getNonIndexedValues().get(1).getValue();
        return typedResponse;
    }

    public Flowable<ClaimRewardsExtraEventResponse> claimRewardsExtraEventFlowable(
            EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getClaimRewardsExtraEventFromLog(log));
    }

    public Flowable<ClaimRewardsExtraEventResponse> claimRewardsExtraEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(CLAIMREWARDSEXTRA_EVENT));
        return claimRewardsExtraEventFlowable(filter);
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

    public static List<InitVaultEventResponse> getInitVaultEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(INITVAULT_EVENT, transactionReceipt);
        ArrayList<InitVaultEventResponse> responses = new ArrayList<InitVaultEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            InitVaultEventResponse typedResponse = new InitVaultEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.vault = (String) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static InitVaultEventResponse getInitVaultEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(INITVAULT_EVENT, log);
        InitVaultEventResponse typedResponse = new InitVaultEventResponse();
        typedResponse.log = log;
        typedResponse.vault = (String) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<InitVaultEventResponse> initVaultEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getInitVaultEventFromLog(log));
    }

    public Flowable<InitVaultEventResponse> initVaultEventFlowable(DefaultBlockParameter startBlock,
            DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(INITVAULT_EVENT));
        return initVaultEventFlowable(filter);
    }

    public static List<SetAdminFeeEventResponse> getSetAdminFeeEvents(
            TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = staticExtractEventParametersWithLog(SETADMINFEE_EVENT, transactionReceipt);
        ArrayList<SetAdminFeeEventResponse> responses = new ArrayList<SetAdminFeeEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            SetAdminFeeEventResponse typedResponse = new SetAdminFeeEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.adminFee = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public static SetAdminFeeEventResponse getSetAdminFeeEventFromLog(Log log) {
        Contract.EventValuesWithLog eventValues = staticExtractEventParametersWithLog(SETADMINFEE_EVENT, log);
        SetAdminFeeEventResponse typedResponse = new SetAdminFeeEventResponse();
        typedResponse.log = log;
        typedResponse.adminFee = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
        return typedResponse;
    }

    public Flowable<SetAdminFeeEventResponse> setAdminFeeEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(log -> getSetAdminFeeEventFromLog(log));
    }

    public Flowable<SetAdminFeeEventResponse> setAdminFeeEventFlowable(
            DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(SETADMINFEE_EVENT));
        return setAdminFeeEventFlowable(filter);
    }

    @Deprecated
    public static IDefaultStakerRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultStakerRewards.abi(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static IDefaultStakerRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new IDefaultStakerRewards.abi(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static IDefaultStakerRewards.abi load(String contractAddress, Web3j web3j,
            Credentials credentials, ContractGasProvider contractGasProvider) {
        return new IDefaultStakerRewards.abi(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static IDefaultStakerRewards.abi load(String contractAddress, Web3j web3j,
            TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new IDefaultStakerRewards.abi(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class ClaimAdminFeeEventResponse extends BaseEventResponse {
        public String recipient;

        public BigInteger amount;
    }

    public static class ClaimRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public String claimer;

        public BigInteger amount;

        public String recipient;
    }

    public static class ClaimRewardsExtraEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public String claimer;

        public BigInteger firstClaimedRewardIndex;

        public BigInteger rewardsClaimed;
    }

    public static class DistributeRewardsEventResponse extends BaseEventResponse {
        public String network;

        public String token;

        public BigInteger distributeAmount;

        public BigInteger adminFeeAmount;

        public BigInteger timestamp;
    }

    public static class InitVaultEventResponse extends BaseEventResponse {
        public String vault;
    }

    public static class SetAdminFeeEventResponse extends BaseEventResponse {
        public BigInteger adminFee;
    }
}
