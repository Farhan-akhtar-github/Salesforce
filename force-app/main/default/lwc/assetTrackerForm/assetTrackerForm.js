import { LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAssets from "@salesforce/apex/AssetTrackerController.getAssets";
import ASSET_OBJECT from "@salesforce/schema/Tracked_Asset__c";
import ASSET_NAME_FIELD from "@salesforce/schema/Tracked_Asset__c.Asset_Name__c";
import SERIAL_FIELD from "@salesforce/schema/Tracked_Asset__c.Serial_Number__c";
import STATUS_FIELD from "@salesforce/schema/Tracked_Asset__c.Status__c";
import CATEGORY_FIELD from "@salesforce/schema/Tracked_Asset__c.Category__c";
import ASSIGNED_TO_FIELD from "@salesforce/schema/Tracked_Asset__c.Assigned_To__c";
import PURCHASE_DATE_FIELD from "@salesforce/schema/Tracked_Asset__c.Purchase_Date__c";
import PURCHASE_PRICE_FIELD from "@salesforce/schema/Tracked_Asset__c.Purchase_Price__c";
import LOCATION_FIELD from "@salesforce/schema/Tracked_Asset__c.Location__c";

const COLUMNS = [
  { label: "Asset #", fieldName: "Name", type: "text", initialWidth: 110 },
  { label: "Asset Name", fieldName: "Asset_Name__c", type: "text" },
  { label: "Serial Number", fieldName: "Serial_Number__c", type: "text" },
  { label: "Status", fieldName: "Status__c", type: "text" },
  { label: "Category", fieldName: "Category__c", type: "text" },
  { label: "Assigned To", fieldName: "assignedToName", type: "text" },
  { label: "Location", fieldName: "Location__c", type: "text" },
  {
    label: "Purchase Price",
    fieldName: "Purchase_Price__c",
    type: "currency",
    cellAttributes: { alignment: "left" }
  }
];

export default class AssetTrackerForm extends LightningElement {
  objectApiName = ASSET_OBJECT;
  columns = COLUMNS;
  assets = [];
  wiredAssets;

  fields = [
    ASSET_NAME_FIELD,
    SERIAL_FIELD,
    STATUS_FIELD,
    CATEGORY_FIELD,
    ASSIGNED_TO_FIELD,
    PURCHASE_DATE_FIELD,
    PURCHASE_PRICE_FIELD,
    LOCATION_FIELD
  ];

  @wire(getAssets)
  loadAssets(result) {
    this.wiredAssets = result;
    if (result.data) {
      this.assets = result.data.map((row) => ({
        ...row,
        assignedToName: row.Assigned_To__r ? row.Assigned_To__r.Name : ""
      }));
    } else if (result.error) {
      this.showToast(
        "Error loading assets",
        this.reduceError(result.error),
        "error"
      );
    }
  }

  get hasAssets() {
    return this.assets && this.assets.length > 0;
  }

  handleSuccess() {
    this.showToast("Success", "Asset saved.", "success");
    this.resetForm();
    return refreshApex(this.wiredAssets);
  }

  handleError(event) {
    const detail =
      event.detail && event.detail.message
        ? event.detail.message
        : "Could not save the asset.";
    this.showToast("Error saving asset", detail, "error");
  }

  handleReset() {
    this.resetForm();
  }

  resetForm() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => field.reset());
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  reduceError(error) {
    if (Array.isArray(error.body)) {
      return error.body.map((e) => e.message).join(", ");
    } else if (error.body && typeof error.body.message === "string") {
      return error.body.message;
    }
    return "Unknown error";
  }
}
