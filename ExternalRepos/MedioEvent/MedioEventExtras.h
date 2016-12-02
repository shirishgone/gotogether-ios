/**
 * Copyright 2012 Medio All rights reserved.
 *
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * THIS IS AUTO GENERATED FILE. DO NOT MODIFY IT.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 */

#import "MedioEvent.h"

#pragma mark - Event type enumerations



#pragma work - Constants

/** The consumable item type. Use this type if users purchase the item each time it is needed. */
extern NSString* const PurchaseItemType_Consumable;
/** The non-consumable item type. Use this type if users purchase the item only once. */
extern NSString* const PurchaseItemType_NonConsumable;
/** The merchandise item type. Use this type if the item purchased is physical merchandise. */
extern NSString* const PurchaseItemType_Merchandise;
/** The virtual currency item type. Use this type if the item purchased is virtual currency. */
extern NSString* const PurchaseItemType_VirtualCurrency;
/** Currency code: AFN */
extern NSString* const Currency_AFN;
/** Currency code: EUR */
extern NSString* const Currency_EUR;
/** Currency code: ALL */
extern NSString* const Currency_ALL;
/** Currency code: DZD */
extern NSString* const Currency_DZD;
/** Currency code: USD */
extern NSString* const Currency_USD;
/** Currency code: AOA */
extern NSString* const Currency_AOA;
/** Currency code: XCD */
extern NSString* const Currency_XCD;
/** Currency code: ARS */
extern NSString* const Currency_ARS;
/** Currency code: AMD */
extern NSString* const Currency_AMD;
/** Currency code: AWG */
extern NSString* const Currency_AWG;
/** Currency code: AUD */
extern NSString* const Currency_AUD;
/** Currency code: AZN */
extern NSString* const Currency_AZN;
/** Currency code: BSD */
extern NSString* const Currency_BSD;
/** Currency code: BHD */
extern NSString* const Currency_BHD;
/** Currency code: BDT */
extern NSString* const Currency_BDT;
/** Currency code: BBD */
extern NSString* const Currency_BBD;
/** Currency code: BYR */
extern NSString* const Currency_BYR;
/** Currency code: BZD */
extern NSString* const Currency_BZD;
/** Currency code: XOF */
extern NSString* const Currency_XOF;
/** Currency code: BMD */
extern NSString* const Currency_BMD;
/** Currency code: BTN */
extern NSString* const Currency_BTN;
/** Currency code: INR */
extern NSString* const Currency_INR;
/** Currency code: BOB */
extern NSString* const Currency_BOB;
/** Currency code: BOV */
extern NSString* const Currency_BOV;
/** Currency code: BAM */
extern NSString* const Currency_BAM;
/** Currency code: BWP */
extern NSString* const Currency_BWP;
/** Currency code: NOK */
extern NSString* const Currency_NOK;
/** Currency code: BRL */
extern NSString* const Currency_BRL;
/** Currency code: BND */
extern NSString* const Currency_BND;
/** Currency code: BGN */
extern NSString* const Currency_BGN;
/** Currency code: BIF */
extern NSString* const Currency_BIF;
/** Currency code: KHR */
extern NSString* const Currency_KHR;
/** Currency code: XAF */
extern NSString* const Currency_XAF;
/** Currency code: CAD */
extern NSString* const Currency_CAD;
/** Currency code: CVE */
extern NSString* const Currency_CVE;
/** Currency code: KYD */
extern NSString* const Currency_KYD;
/** Currency code: CLF */
extern NSString* const Currency_CLF;
/** Currency code: CLP */
extern NSString* const Currency_CLP;
/** Currency code: CNY */
extern NSString* const Currency_CNY;
/** Currency code: COP */
extern NSString* const Currency_COP;
/** Currency code: COU */
extern NSString* const Currency_COU;
/** Currency code: KMF */
extern NSString* const Currency_KMF;
/** Currency code: CDF */
extern NSString* const Currency_CDF;
/** Currency code: NZD */
extern NSString* const Currency_NZD;
/** Currency code: CRC */
extern NSString* const Currency_CRC;
/** Currency code: HRK */
extern NSString* const Currency_HRK;
/** Currency code: CUC */
extern NSString* const Currency_CUC;
/** Currency code: CUP */
extern NSString* const Currency_CUP;
/** Currency code: ANG */
extern NSString* const Currency_ANG;
/** Currency code: CZK */
extern NSString* const Currency_CZK;
/** Currency code: DKK */
extern NSString* const Currency_DKK;
/** Currency code: DJF */
extern NSString* const Currency_DJF;
/** Currency code: DOP */
extern NSString* const Currency_DOP;
/** Currency code: EGP */
extern NSString* const Currency_EGP;
/** Currency code: SVC */
extern NSString* const Currency_SVC;
/** Currency code: ERN */
extern NSString* const Currency_ERN;
/** Currency code: ETB */
extern NSString* const Currency_ETB;
/** Currency code: FKP */
extern NSString* const Currency_FKP;
/** Currency code: FJD */
extern NSString* const Currency_FJD;
/** Currency code: XPF */
extern NSString* const Currency_XPF;
/** Currency code: GMD */
extern NSString* const Currency_GMD;
/** Currency code: GEL */
extern NSString* const Currency_GEL;
/** Currency code: GHS */
extern NSString* const Currency_GHS;
/** Currency code: GIP */
extern NSString* const Currency_GIP;
/** Currency code: GTQ */
extern NSString* const Currency_GTQ;
/** Currency code: GBP */
extern NSString* const Currency_GBP;
/** Currency code: GNF */
extern NSString* const Currency_GNF;
/** Currency code: GYD */
extern NSString* const Currency_GYD;
/** Currency code: HTG */
extern NSString* const Currency_HTG;
/** Currency code: HNL */
extern NSString* const Currency_HNL;
/** Currency code: HKD */
extern NSString* const Currency_HKD;
/** Currency code: HUF */
extern NSString* const Currency_HUF;
/** Currency code: ISK */
extern NSString* const Currency_ISK;
/** Currency code: IDR */
extern NSString* const Currency_IDR;
/** Currency code: XDR */
extern NSString* const Currency_XDR;
/** Currency code: IRR */
extern NSString* const Currency_IRR;
/** Currency code: IQD */
extern NSString* const Currency_IQD;
/** Currency code: ILS */
extern NSString* const Currency_ILS;
/** Currency code: JMD */
extern NSString* const Currency_JMD;
/** Currency code: JPY */
extern NSString* const Currency_JPY;
/** Currency code: JOD */
extern NSString* const Currency_JOD;
/** Currency code: KZT */
extern NSString* const Currency_KZT;
/** Currency code: KES */
extern NSString* const Currency_KES;
/** Currency code: KPW */
extern NSString* const Currency_KPW;
/** Currency code: KRW */
extern NSString* const Currency_KRW;
/** Currency code: KWD */
extern NSString* const Currency_KWD;
/** Currency code: KGS */
extern NSString* const Currency_KGS;
/** Currency code: LAK */
extern NSString* const Currency_LAK;
/** Currency code: LVL */
extern NSString* const Currency_LVL;
/** Currency code: LBP */
extern NSString* const Currency_LBP;
/** Currency code: LSL */
extern NSString* const Currency_LSL;
/** Currency code: ZAR */
extern NSString* const Currency_ZAR;
/** Currency code: LRD */
extern NSString* const Currency_LRD;
/** Currency code: LYD */
extern NSString* const Currency_LYD;
/** Currency code: CHF */
extern NSString* const Currency_CHF;
/** Currency code: LTL */
extern NSString* const Currency_LTL;
/** Currency code: MOP */
extern NSString* const Currency_MOP;
/** Currency code: MKD */
extern NSString* const Currency_MKD;
/** Currency code: MGA */
extern NSString* const Currency_MGA;
/** Currency code: MWK */
extern NSString* const Currency_MWK;
/** Currency code: MYR */
extern NSString* const Currency_MYR;
/** Currency code: MVR */
extern NSString* const Currency_MVR;
/** Currency code: MRO */
extern NSString* const Currency_MRO;
/** Currency code: MUR */
extern NSString* const Currency_MUR;
/** Currency code: XUA */
extern NSString* const Currency_XUA;
/** Currency code: MXN */
extern NSString* const Currency_MXN;
/** Currency code: MXV */
extern NSString* const Currency_MXV;
/** Currency code: MDL */
extern NSString* const Currency_MDL;
/** Currency code: MNT */
extern NSString* const Currency_MNT;
/** Currency code: MAD */
extern NSString* const Currency_MAD;
/** Currency code: MZN */
extern NSString* const Currency_MZN;
/** Currency code: MMK */
extern NSString* const Currency_MMK;
/** Currency code: NAD */
extern NSString* const Currency_NAD;
/** Currency code: NPR */
extern NSString* const Currency_NPR;
/** Currency code: NIO */
extern NSString* const Currency_NIO;
/** Currency code: NGN */
extern NSString* const Currency_NGN;
/** Currency code: OMR */
extern NSString* const Currency_OMR;
/** Currency code: PKR */
extern NSString* const Currency_PKR;
/** Currency code: PAB */
extern NSString* const Currency_PAB;
/** Currency code: PGK */
extern NSString* const Currency_PGK;
/** Currency code: PYG */
extern NSString* const Currency_PYG;
/** Currency code: PEN */
extern NSString* const Currency_PEN;
/** Currency code: PHP */
extern NSString* const Currency_PHP;
/** Currency code: PLN */
extern NSString* const Currency_PLN;
/** Currency code: QAR */
extern NSString* const Currency_QAR;
/** Currency code: RON */
extern NSString* const Currency_RON;
/** Currency code: RUB */
extern NSString* const Currency_RUB;
/** Currency code: RWF */
extern NSString* const Currency_RWF;
/** Currency code: SHP */
extern NSString* const Currency_SHP;
/** Currency code: WST */
extern NSString* const Currency_WST;
/** Currency code: STD */
extern NSString* const Currency_STD;
/** Currency code: SAR */
extern NSString* const Currency_SAR;
/** Currency code: RSD */
extern NSString* const Currency_RSD;
/** Currency code: SCR */
extern NSString* const Currency_SCR;
/** Currency code: SLL */
extern NSString* const Currency_SLL;
/** Currency code: SGD */
extern NSString* const Currency_SGD;
/** Currency code: XSU */
extern NSString* const Currency_XSU;
/** Currency code: SBD */
extern NSString* const Currency_SBD;
/** Currency code: SOS */
extern NSString* const Currency_SOS;
/** Currency code: SSP */
extern NSString* const Currency_SSP;
/** Currency code: LKR */
extern NSString* const Currency_LKR;
/** Currency code: SDG */
extern NSString* const Currency_SDG;
/** Currency code: SRD */
extern NSString* const Currency_SRD;
/** Currency code: SZL */
extern NSString* const Currency_SZL;
/** Currency code: SEK */
extern NSString* const Currency_SEK;
/** Currency code: CHE */
extern NSString* const Currency_CHE;
/** Currency code: CHW */
extern NSString* const Currency_CHW;
/** Currency code: SYP */
extern NSString* const Currency_SYP;
/** Currency code: TWD */
extern NSString* const Currency_TWD;
/** Currency code: TJS */
extern NSString* const Currency_TJS;
/** Currency code: TZS */
extern NSString* const Currency_TZS;
/** Currency code: THB */
extern NSString* const Currency_THB;
/** Currency code: TOP */
extern NSString* const Currency_TOP;
/** Currency code: TTD */
extern NSString* const Currency_TTD;
/** Currency code: TND */
extern NSString* const Currency_TND;
/** Currency code: TRY */
extern NSString* const Currency_TRY;
/** Currency code: TMT */
extern NSString* const Currency_TMT;
/** Currency code: UGX */
extern NSString* const Currency_UGX;
/** Currency code: UAH */
extern NSString* const Currency_UAH;
/** Currency code: AED */
extern NSString* const Currency_AED;
/** Currency code: USN */
extern NSString* const Currency_USN;
/** Currency code: USS */
extern NSString* const Currency_USS;
/** Currency code: UYI */
extern NSString* const Currency_UYI;
/** Currency code: UYU */
extern NSString* const Currency_UYU;
/** Currency code: UZS */
extern NSString* const Currency_UZS;
/** Currency code: VUV */
extern NSString* const Currency_VUV;
/** Currency code: VEF */
extern NSString* const Currency_VEF;
/** Currency code: VND */
extern NSString* const Currency_VND;
/** Currency code: YER */
extern NSString* const Currency_YER;
/** Currency code: ZMK */
extern NSString* const Currency_ZMK;
/** Currency code: ZWL */
extern NSString* const Currency_ZWL;
/** Currency code: XBB */
extern NSString* const Currency_XBB;
/** Currency code: XBC */
extern NSString* const Currency_XBC;
/** Currency code: XBD */
extern NSString* const Currency_XBD;
/** Currency code: XFU */
extern NSString* const Currency_XFU;
/** Currency code: XTS */
extern NSString* const Currency_XTS;
/** Currency code: XXX */
extern NSString* const Currency_XXX;
/** Currency code: XAU */
extern NSString* const Currency_XAU;
/** Currency code: XPD */
extern NSString* const Currency_XPD;
/** Currency code: XPT */
extern NSString* const Currency_XPT;
/** Currency code: XAG */
extern NSString* const Currency_XAG;

#pragma mark - Event-specific options

/**
 * Log an event indicating that the user purchased an item in the application.
 */
@interface LogPurchaseOptions : NSObject
/** The type of item purchased. */
@property (nonatomic, strong) NSString* itemType;
/** Category tag for the purchased item. */
@property (nonatomic, strong) NSString* itemCategoryTag;
/** Referrer for the purchase. The referrer is a place within your application where the user came from before making the purchase. */
@property (nonatomic, strong) NSString* referrer;
+ (id)options;
@end

/**
 * Log an event indicating that your application earned revenue as a result of an action.
 */
@interface LogEarnOptions : NSObject
/** Identifier for the earn event. */
@property (nonatomic, strong) NSString* earnId;
/** Type of the earned revenue. */
@property (nonatomic, strong) NSString* earnType;
+ (id)options;
@end



/**
 * Medio Event extras.
 */
@interface MedioEvent (Extras)

#pragma mark - Generated event common properties

/** Logs the promotional campaign that the user was acquired from. */
@property (nonatomic, retain) NSString* campaign;
/** Logs the channel that the user was acquired from. For example, a user may be acquired through an advertising network or keyword search channel. */
@property (nonatomic, retain) NSString* acquisitionChannel;
/** Purchase cart id. */
@property (nonatomic, retain) NSString* purchaseCartId;

#pragma mark - Generated methods

/** Open purchase cart. Call this method to start purchase transaction. */
- (void)openPurchaseCart;
/** Close purchase cart. Call this method to close purchase transaction. */
- (void)closePurchaseCart;


/**
 * Log an event indicating that the user purchased an item in the application.
 * @param theItemId
 *        Your identifier for the item such as a Stock Keeping Unit (SKU).
 * @param theUnitPrice
 *        The price of the purchased item(s).
 * @param theCurrency
 *        The ISO 4217 alphabetic code for the currency used to purchase the item. For example, use the code USD for US Dollars.
 * @param theIsCurrencyVirtual
 *        Pass true to mark currency as virtual, false otherwise.
 * @param theQuantity
 *        The quantity of item(s) purchased.
 * @param $options
 *        Additional options.
 * @param $paramsMap
 *        Optional (user-defined) list of keys/values to add to event.
 * @return
 *        true, if event was successfully logged; false, otherwise.
 */
- (BOOL)logPurchaseEventWithItemId:(NSString*)theItemId unitPrice:(double)theUnitPrice currency:(NSString*)theCurrency isCurrencyVirtual:(BOOL)theIsCurrencyVirtual quantity:(int)theQuantity withOptions:(LogPurchaseOptions*)$options andParameters:(NSDictionary*)$paramsMap;

/**
 * Log an event indicating that your application earned revenue as a result of an action.
 * @param theEarnAmount
 *        The amount of revenue earned.
 * @param theCurrency
 *        The ISO 4217 alphabetic code for the currency of the earned amount. For example, use the code USD for US Dollars.
 * @param $options
 *        Additional options.
 * @param $paramsMap
 *        Optional (user-defined) list of keys/values to add to event.
 * @return
 *        true, if event was successfully logged; false, otherwise.
 */
- (BOOL)logEarnEventWithEarnAmount:(double)theEarnAmount currency:(NSString*)theCurrency withOptions:(LogEarnOptions*)$options andParameters:(NSDictionary*)$paramsMap;


@end
