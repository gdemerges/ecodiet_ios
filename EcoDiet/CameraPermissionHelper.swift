//
//  CameraPermissionHelper.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import AVFoundation
import SwiftUI

/// Helper pour gérer les permissions de la caméra
struct CameraPermissionHelper {
    
    enum PermissionStatus {
        case authorized
        case denied
        case notDetermined
    }
    
    /// Vérifie le statut actuel des permissions
    static func checkPermission() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    /// Demande la permission d'utiliser la caméra
    static func requestPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    /// Ouvre les paramètres de l'application
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

/// Vue d'alerte pour les permissions de caméra refusées
struct CameraPermissionDeniedView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.2),
                                    Color.red.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "camera.fill.badge.ellipsis")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.orange,
                                    Color.red
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 12) {
                    Text("Permission caméra refusée")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Pour scanner des codes-barres, EcoDiet a besoin d'accéder à votre caméra.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    Button {
                        CameraPermissionHelper.openSettings()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Ouvrir les réglages")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                    Color(red: 0.2, green: 0.6, blue: 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 32)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Annuler")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 12)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Permission requise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview("Permission refusée") {
    CameraPermissionDeniedView()
}
