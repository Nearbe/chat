import SwiftUI
import UIKit

/// Интерактивный 3D щит с пульсацией и наклоном
struct ShieldView: View {
    let onTokenReceived: (String) -> Void
    
    @State private var shieldScale: CGFloat = 1.0
    @State private var shieldRotationX: Double = 0
    @State private var shieldRotationY: Double = 0
    @State private var isPulsing = true
    @State private var fingerOnShield = false
    @State private var pulseKey: Int = 0
    @State private var idleRotation: Double = 0
    
    private let shieldSize: CGFloat = 280
    private let shieldW: CGFloat = 125
    private let shieldH: CGFloat = 150
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let halfSize = size / 2
            let halfShieldW = shieldW / 2
            let halfShieldH = shieldH / 2
            
            ZStack {
                // Невидимый слой для жестов
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: size, height: size)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                let isInsideZone = location.x >= 0 && location.x <= size &&
                                                   location.y >= 0 && location.y <= size
                                let isInsideShield = location.x >= halfSize - halfShieldW &&
                                                      location.x <= halfSize + halfShieldW &&
                                                      location.y >= halfSize - halfShieldH &&
                                                      location.y <= halfSize + halfShieldH
                                
                                if isInsideShield {
                                    fingerOnShield = true
                                    
                                    if isPulsing {
                                        isPulsing = false
                                    }
                                    
                                    // Наклон щита
                                    let normalizedX = (location.x - halfSize) / halfShieldW
                                    let normalizedY = (location.y - halfSize) / halfShieldH
                                    let rotationX = -normalizedY * 25
                                    let rotationY = normalizedX * 25
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        shieldRotationX = rotationX
                                        shieldRotationY = rotationY
                                    }
                                } else if isInsideZone && !isInsideShield {
                                    fingerOnShield = false
                                    isPulsing = false
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2)) {
                                        shieldRotationX = 0
                                        shieldRotationY = 0
                                    }
                                } else if !isInsideZone {
                                    fingerOnShield = false
                                    isPulsing = true
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2)) {
                                        shieldRotationX = 0
                                        shieldRotationY = 0
                                    }
                                    pulseKey += 1
                                }
                            }
                            .onEnded { _ in
                                let wasOnShield = fingerOnShield
                                fingerOnShield = false
                                isPulsing = true
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.3)) {
                                    shieldRotationX = 0
                                    shieldRotationY = 0
                                }
                                
                                pulseKey += 1
                                
                                // Обработка тапа - проверка токена
                                if wasOnShield {
                                    if let pasteboardString = UIPasteboard.general.string,
                                       !pasteboardString.isEmpty,
                                       pasteboardString.hasPrefix("sk-lm") {
                                        onTokenReceived(pasteboardString)
                                    } else {
                                        // Показываем ошибку через NotificationCenter
                                        NotificationCenter.default.post(
                                            name: .shieldTapError,
                                            object: nil,
                                            userInfo: ["message": "Неверный токен. Должен начинаться с «sk-lm»"]
                                        )
                                    }
                                }
                            }
                    )
                
                // Щит с 3D эффектом
                ZStack {
                    // Основной щит
                    Image(systemName: "shield.fill")
                        .font(.system(size: shieldSize))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    ThemeManager.shared.accentColor,
                                    ThemeManager.shared.accentColor.opacity(0.7),
                                    ThemeManager.shared.accentColor.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
                        .scaleEffect(shieldScale)
                        .rotation3DEffect(.degrees(shieldRotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                        .rotation3DEffect(.degrees(shieldRotationY + idleRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)

                    // Замок
                    Image(systemName: "lock.fill")
                        .font(.system(size: 75, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .scaleEffect(shieldScale)
                        .rotation3DEffect(.degrees(shieldRotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                        .rotation3DEffect(.degrees(shieldRotationY + idleRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                        .allowsHitTesting(false)
                }
                .allowsHitTesting(false)
                .id(pulseKey)
                .onChange(of: pulseKey) { _, _ in
                    shieldScale = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                            shieldScale = 1.1
                        }
                    }
                }
                .onAppear {
                    // Idle анимация для постоянного 3D эффекта
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        idleRotation = 8
                    }
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                        shieldScale = 1.1
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: halfSize, y: halfSize)
        }
    }
}

extension Notification.Name {
    static let shieldTapError = Notification.Name("shieldTapError")
}

#Preview {
    ShieldView(onTokenReceived: { token in
        print("Token received: \(token)")
    })
    .frame(width: 400, height: 400)
    .background(Color.black)
}
