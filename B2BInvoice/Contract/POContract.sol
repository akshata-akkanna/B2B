pragma solidity ^0.4.18;
import "./ShipmentContract.sol";
/*
  This contract is used by Seller to issue Purchase Order
*/
contract POContract {

    address owner;

    function POContract() public {
        owner = msg.sender;
    }

    modifier onlySeller() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender != owner);
        _;
    }

    struct PurchaseOrderDetail {
        uint rfqID;
        uint poNumber;
        string description;
        uint poReqDate;
        string poFileName;
        string poFileHash;
    }

    mapping (uint=>PurchaseOrderDetail) PurchaseOrderDetails;
    mapping (uint=>uint) RFQtoPO; // RFQ to PO Number Lookup

    uint PURCHASE_ORDER_COUNTER;
    
    struct InvoiceDetail {
        uint poNumber;
        uint invoiceNumber;
        uint reqDate;
        string reqBy;
        string invoiceReceiptFileName;
        string invoiceReceiptFileHash;
    }
    mapping (uint=>InvoiceDetail) InvoiceDetails;
    uint INVOICE_NUMBER;

    struct PackageDetail {
        uint poNumber;
        uint packageID;
        uint reqDate;
        string reqBy;
        string packageDescription;
        string packageSlipFileName;
        string packageSlipFileHash;
    }
    mapping (uint=>PackageDetail) PackageDetails;
    uint PACKAGE_NUMBER;

    struct POMapping {
        uint poNumber;
        uint invoiceNumber;
        uint packageID;
    }

    mapping(uint=>POMapping) poInvoicePackage;

    ShipmentContract shipmentContractAddr;

    event PurchaseOrderCreated(uint rfqID,uint ponumber,bool status);
    event InvoiceCreated(uint ponumber,uint invoiceNumber,bool status);
    event PackageSlipCreated(uint ponumber,uint packageID,bool status);

    // This method is used by the buyer to create Purchase Order
    
    function createPurchaseOrder(uint rfqID,string description,uint poReqDate, string poFileName, string poFileHash ) onlyBuyer public {
        
        require(rfqID>0);
        require(poReqDate>0);
        
        PurchaseOrderDetails[PURCHASE_ORDER_COUNTER] = PurchaseOrderDetail(rfqID,PURCHASE_ORDER_COUNTER+1,description,poReqDate,poFileName,poFileHash);
       // Successful purchase order creation
        PurchaseOrderCreated(rfqID,PURCHASE_ORDER_COUNTER+1,true);
        RFQtoPO[rfqID] = PURCHASE_ORDER_COUNTER+1;
        PURCHASE_ORDER_COUNTER++;
    }

    // This method is used to get the overall PO count
    function getPurchaseOrderCount() view public returns (uint) { 
        return PURCHASE_ORDER_COUNTER;
    }

    // This method is used to get the  by PO number by RFQID
    function getPONumberByrfqID(uint rfqID) view public returns (uint poNumber) {
        return RFQtoPO[rfqID];
    }

    // This method is used to get the respective PO detail
    function getPurchaseOrderDetailByPOIndex(uint poIndex) view public returns (uint rfqID,uint poNumber, string description,uint poReqDate, string fileName, string fileHash) {
        // Getting the appropriate PO details
        rfqID = PurchaseOrderDetails[poIndex].rfqID;
        poNumber = PurchaseOrderDetails[poIndex].poNumber;
        description = PurchaseOrderDetails[poIndex].description;
        poReqDate = PurchaseOrderDetails[poIndex].poReqDate;
        fileName = PurchaseOrderDetails[poIndex].poFileName;
        fileHash = PurchaseOrderDetails[poIndex].poFileHash;
    }

    // This method is used by Seller to generate invoice
    function createInvoice(uint invoiceDate,string reqBy,uint poNumber,string invoiceReceiptFileName,string invoiceReceiptFileHash) onlySeller public {
        require(poNumber>0);
        // Populate Invoice Details
        InvoiceDetails[INVOICE_NUMBER] = InvoiceDetail(poNumber,INVOICE_NUMBER+1,invoiceDate,reqBy,invoiceReceiptFileName,invoiceReceiptFileHash);
        POMapping storage poMapping = poInvoicePackage[poNumber];
        poMapping.poNumber = poNumber;
        poMapping.invoiceNumber = INVOICE_NUMBER+1;
        // Successful Invoice Generation - Event Raised
        InvoiceCreated(poNumber,INVOICE_NUMBER+1,true);
        INVOICE_NUMBER++;
    }

    // This method is used by Seller to generate Package Slip - which inturn issues shipment
    function createPackageSlip(uint reqDate,string reqBy,string packageDescription, uint poNumber,string packageSlipFileName, string packageSlipFileHash ) onlySeller public {
        require(poNumber>0);
        // Populate PackageSlip Details
        PackageDetails[PACKAGE_NUMBER] = PackageDetail(poNumber,PACKAGE_NUMBER+1,reqDate,reqBy,packageDescription,packageSlipFileName,packageSlipFileHash);
        POMapping storage poMapping = poInvoicePackage[poNumber];
        poMapping.packageID = PACKAGE_NUMBER+1;
        // Successful PackageSlip Generation - Event Raised
        PackageSlipCreated(poNumber,PACKAGE_NUMBER+1,true);
        PACKAGE_NUMBER++;
    }

    // This method is used get the total invoice count
    function getInvoiceCount() view public returns (uint) {
        return INVOICE_NUMBER;
    }

    // This method is used get the total package slip count
    function getPackageSlipCount() view public returns (uint) {
        return PACKAGE_NUMBER;
    }

    // This method is used get the invoice detail based on invoice Index
    function getInvoiceDetailsByInvoiceIndex(uint invoiceIndex) view public returns (uint poNumber, uint invoiceNumber, string invoiceReceiptFileName, string invoiceReceiptFileHash, uint invoiceDate, string requestBy) {
        // Getting the appropriate Invoice details
        poNumber = InvoiceDetails[invoiceIndex].poNumber;
        invoiceNumber = InvoiceDetails[invoiceIndex].invoiceNumber;
        invoiceReceiptFileName = InvoiceDetails[invoiceIndex].invoiceReceiptFileName;
        invoiceReceiptFileHash = InvoiceDetails[invoiceIndex].invoiceReceiptFileHash;
        invoiceDate = InvoiceDetails[invoiceIndex].reqDate;
        requestBy = InvoiceDetails[invoiceIndex].reqBy;
    }

    // This method is used to get the Invoice number and Package ID based on PO Number
    function getInvoiceAndPackageByPO(uint poNumber) view public returns (uint invoiceNumber,uint packageID) {
        invoiceNumber = poInvoicePackage[poNumber].invoiceNumber;
        packageID = poInvoicePackage[poNumber].packageID;
    }

    // This method is used get the invoice detail based on invoice Index
    function getPackageDetailsByPackageIndex(uint packageIndex) view public returns (uint poNumber, uint packageID, string packageDescription,string packageSlipFileName, string packageSlipFileHash, uint reqDate, string reqBy) {
        // Getting the appropriate Invoice details
        poNumber = PackageDetails[packageIndex].poNumber;
        packageID = PackageDetails[packageIndex].packageID;
        packageDescription = PackageDetails[packageIndex].packageDescription;
        packageSlipFileName = PackageDetails[packageIndex].packageSlipFileName;
        packageSlipFileHash = PackageDetails[packageIndex].packageSlipFileHash;
        reqDate = PackageDetails[packageIndex].reqDate;
        reqBy = PackageDetails[packageIndex].reqBy;
    }
}