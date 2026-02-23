// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Утилита для симуляции Touch ID / Face ID в UI тестах
@interface UTBiometric : NSObject

/// Зарегистрировать биометрию (Touch ID/Face ID доступны)
+ (void)enrolled;

/// Отменить регистрацию биометрии (Touch ID/Face ID недоступны)
+ (void)unenrolled;

/// Симулировать успешную аутентификацию
+ (void)successfulAuthentication;

/// Симулировать неуспешную аутентификацию
+ (void)unsuccessfulAuthentication;

@end

NS_ASSUME_NONNULL_END
