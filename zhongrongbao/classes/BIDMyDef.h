//
//  BIDMyDef.h
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#ifndef zhongrongbao_BIDMyDef_h
#define zhongrongbao_BIDMyDef_h

/**
 *标的状态(投标中、满标、还款、已还完、准备中、流标、废弃)
 */
typedef enum TENDER_STATUS
{
    STATUS_TENDERRING, STATUS_FULL, STATUS_REPAY, STATUS_REPAID, STATUS_READY, STATUS_LIUBIAO, STATUS_DISCARD, STATUS_TRANSFER, STATUS_PUBLISHING
}TENDER_STATUS;
/**
 *标详情模块（项目信息、个人/企业信息、风控信息、抵质押信息、图片信息）
 */
typedef enum MODULE_TYPE
{
    TYPE_PROJECT, TYPE_ENTERPRISE, TYPE_RISK, TYPE_MORTGAGE, TYPE_IMG
}MODULE_TYPE;
/**
 *活动类型（红包、体验金）
 */
typedef enum ACTIVITY_TYPE
{
    ACTIVITY_REDPACKET, ACTIVITY_TIYANJIN
}ACTIVITY_TYPE;

#endif
