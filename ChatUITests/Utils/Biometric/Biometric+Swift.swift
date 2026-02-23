// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Swift обёртка для Biometric - утилиты симуляции Touch ID / Face ID
@MainActor
public enum Biometric {

    /// Зарегистрировать биометрию (Touch ID/Face ID будут доступны)
    public static func enrolled() {
        XCTContext.runActivity(named: "Biometric: enrolled") { _ in
            UTBiometricObjc.enrolled()
        }
    }

    /// Отменить регистрацию биометрии (Touch ID/Face ID не будут доступны)
    public static func unenrolled() {
        XCTContext.runActivity(named: "Biometric: unenrolled") { _ in
            UTBiometricObjc.unenrolled()
        }
    }

    /// Симулировать успешную аутентификацию (Face ID / Touch ID успешен)
    public static func successfulAuthentication() {
        XCTContext.runActivity(named: "Biometric: successful authentication") { _ in
            UTBiometricObjc.successfulAuthentication()
        }
    }

    /// Симулировать неуспешную аутентификацию (Face ID / Touch ID провален)
    public static func unsuccessfulAuthentication() {
        XCTContext.runActivity(named: "Biometric: unsuccessful authentication") { _ in
            UTBiometricObjc.unsuccessfulAuthentication()
        }
    }
}

/// Утилита для настройки биометрии в тестах
@MainActor
public final class BiometricHelper {

    /// Включить биометрию и симулировать успешную аутентификацию
    public static func allow() {
        Biometric.enrolled()
        Biometric.successfulAuthentication()
    }

    /// Отключить биометрию
    public static func deny() {
        Biometric.unenrolled()
    }

    /// Симулировать неудачную попытку аутентификации
    public static func failAuthentication() {
        Biometric.unsuccessfulAuthentication()
    }
}
