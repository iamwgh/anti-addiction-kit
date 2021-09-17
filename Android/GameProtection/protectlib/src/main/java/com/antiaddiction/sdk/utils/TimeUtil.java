package com.antiaddiction.sdk.utils;

import com.antiaddiction.sdk.AntiAddictionKit;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;

public class TimeUtil {
    // 2021年节假日
    private static final String[] HOLIDAY_2021 = {
            "0101", //元旦1天
            "0212", "0213", "0214", //春节3天
            "0404", //清明1天
            "0501", //劳动节1天
            "0614", //端午节 1天
            "0921",   // 中秋1天
            "1001", "1002", "1003", //国庆 3天
    };

    /**
     * 获取玩家可玩的剩余时间
     *
     * @return -1: 不在可玩时间段内(周五、周六、周日、法定节假日 20:00 至 21:00)；
     *         remainTime: 距离 21:00 还剩余的时间
     */
    public static int getUserPlayableRemainTime() {
        if (!isDayDuringPlayableTimePeriod()) {
            return -1;
        }
        long currentTime = new Date().getTime();
        SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
        String dateString = formatter.format(currentTime);
        String[] currentTimeArray = dateString.split(":");

        String curHour = currentTimeArray[0];
        String curMin = currentTimeArray[1];
        String curSecond = currentTimeArray[2];

        int timeStrictStart = AntiAddictionKit.getCommonConfig().getTimeStrictStart(); // 限制时间范围的起始时间 晚上8点
        int timeStrictEnd = AntiAddictionKit.getCommonConfig().getTimeStrictEnd(); // 限制时间范围的结束时间 晚上9点

        int currentTimeSec = Integer.parseInt(curHour) * 60 * 60 + Integer.parseInt(curMin) * 60 + Integer.parseInt(curSecond); // 当前时间秒数
        if (currentTimeSec >= timeStrictStart && currentTimeSec < timeStrictEnd) {
            // 当前时间秒数在限制时间范围的范围内
            return timeStrictEnd - currentTimeSec;
        } else {
            return -1;
//            if (currentTimeSec < timeStrictStart) {
//                return timeStrictStart - currentTimeSec;
//            } else {
//                // 当前时间秒数在限制时间范围结束时间之后，算的是距离第二天可玩时间范围还有多久
//                return 24 * 60 * 60 - currentTimeSec + timeStrictStart;
//            }
        }
    }

    //距离可玩时间段还有多久，单位秒
//    public static int getTimeToNightStrict(){
//        long currentTime = new Date().getTime();
//        SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
//        String dateString = formatter.format(currentTime);
//        int hour = Integer.parseInt(dripZero(dateString.substring(0,2)));
//        int min = Integer.parseInt(dripZero(dateString.substring(3,5)));
//        int second = Integer.parseInt(dripZero(dateString.substring(6)));
//        int startTime = AntiAddictionKit.getCommonConfig().getNightStrictStart();
//        int endTime = AntiAddictionKit.getCommonConfig().getNightStrictEnd();
//        int currentSecondTime = hour * 60 * 60 + min * 60 + second;
//        if(startTime > endTime) {
//            if (currentSecondTime > startTime || currentSecondTime < endTime || currentSecondTime == startTime || currentSecondTime == endTime) {
//                return 0;
//            } else {
//                return startTime - currentSecondTime;
//            }
//        }else{
//            if(currentSecondTime > startTime && currentSecondTime < endTime || currentSecondTime == startTime || currentSecondTime == endTime){
//                return 0;
//            }else{
//                if(currentSecondTime < startTime){
//                    return startTime - currentSecondTime;
//                }else{
//                    return 24 * 3600 - currentSecondTime + startTime;
//                }
//            }
//        }
//    }

    //距离限制时长还有多久，单位秒
//    public static int getTimeToStrict(User user){
//        int hasUse = user.getOnlineTime();
//        if(user.getAccountType() != AntiAddictionKit.USER_TYPE_UNKNOWN) {
//            if (isHoliday()) {
//                return AntiAddictionKit.getCommonConfig().getChildHolidayTime() - hasUse;
//            } else {
//                return AntiAddictionKit.getCommonConfig().getChildCommonTime() - hasUse;
//            }
//        }else{
//            return AntiAddictionKit.getCommonConfig().getGuestTime() - hasUse;
//        }
//    }

    /**
     * 周五、周六、周日、法定节假日 20:00 至 21:00 才是可玩时间段 (2021年9月1日新政策)
     *
     * @return
     */
    public static boolean isDayDuringPlayableTimePeriod(){
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date());
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        int[] dayOfWeekArray = AntiAddictionKit.getCommonConfig().getDayOfWeekArray();
        for (int dayField : dayOfWeekArray) {
            if (dayField == dayOfWeek) {
                return true;
            }
        }
        long currentTime = new Date().getTime();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy:MM:dd");
        String dateString = formatter.format(currentTime);
        String[] date = dateString.split(":");
        String year = date[0];
        String month = date[1];
        String day = date[2];

        //考虑到单机游戏，暂时假日写死
        String[] currentYear = null;
        if ("2021".equals(year)) {
            currentYear = HOLIDAY_2021;
        }
        String current = month + day;
        return currentYear != null && Arrays.asList(currentYear).contains(current);
    }

    private static String dripZero(String str){
        if(str != null && str.length() > 1){
            if(str.startsWith("0")){
                return str.substring(1);
            }else{
                return str;
            }
        }else{
            return str;
        }
    }
    //返回分钟,例如22：10返回22*3600 + 10 * 60
    public static int getTimeByClock(String clock){
        if(clock == null || clock.length() == 0){
            return 0;
        }
        int hour = Integer.parseInt(dripZero(clock.substring(0,2)));
        int min = Integer.parseInt(dripZero(clock.substring(3)));
        return hour * 3600 + min * 60;
    }
}
