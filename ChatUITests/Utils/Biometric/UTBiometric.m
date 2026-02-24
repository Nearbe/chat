// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

#import "UTBiometric.h"
#import "notify.h"

@implementation UTBiometric

+ (void)enrolled {
    [self postEnrollment:YES];
}

+ (void)unenrolled {
    [self postEnrollment:NO];
}

+ (void)successfulAuthentication {
    notify_post("com.apple.BiometricKit_Sim.fingerTouch.match");
    notify_post("com.apple.BiometricKit_Sim.pearl.match");
}

+ (void)unsuccessfulAuthentication {
    notify_post("com.apple.BiometricKit_Sim.fingerTouch.nomatch");
    notify_post("com.apple.BiometricKit_Sim.pearl.nomatch");
}

+ (void)postEnrollment:(BOOL)isEnrolled {
    int token;
    notify_register_check("com.apple.BiometricKit.enrollmentChanged", &token);
    notify_set_state(token, isEnrolled ? 1 : 0);
    notify_post("com.apple.BiometricKit.enrollmentChanged");
}

@end
