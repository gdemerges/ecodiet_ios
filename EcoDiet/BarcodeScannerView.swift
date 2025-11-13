//
//  BarcodeScannerView.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import SwiftUI
import AVFoundation

/// Vue pour scanner des codes-barres avec la caméra
struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannerCoordinator: BarcodeScannerCoordinator
    
    let onBarcodeScanned: (String) -> Void
    
    init(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned
        self._scannerCoordinator = State(initialValue: BarcodeScannerCoordinator(onBarcodeScanned: onBarcodeScanned))
    }
    
    var body: some View {
        ZStack {
            // Vue de la caméra
            BarcodeScannerRepresentable(coordinator: scannerCoordinator)
                .ignoresSafeArea()
            
            // Overlay avec cadre de scan
            VStack {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Zone de scan avec cadre
                scanFrame
                
                Spacer()
                
                // Instructions
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                        
                        Text("Scannez un code-barres")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    
                    Text("Positionnez le code-barres dans le cadre")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.8))
                )
                .padding(.bottom, 40)
            }
            
            // État du scanner
            if scannerCoordinator.isScanning {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        
                        Text("Analyse en cours...")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.9))
                    )
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            scannerCoordinator.startScanning()
        }
        .onDisappear {
            scannerCoordinator.stopScanning()
        }
    }
    
    private var scanFrame: some View {
        ZStack {
            // Coins du cadre
            GeometryReader { geometry in
                let size: CGFloat = 250
                let cornerLength: CGFloat = 30
                let cornerWidth: CGFloat = 4
                
                // Coin supérieur gauche
                Path { path in
                    path.move(to: CGPoint(x: 0, y: cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: cornerLength, y: 0))
                }
                .stroke(Color.white, lineWidth: cornerWidth)
                
                // Coin supérieur droit
                Path { path in
                    path.move(to: CGPoint(x: size - cornerLength, y: 0))
                    path.addLine(to: CGPoint(x: size, y: 0))
                    path.addLine(to: CGPoint(x: size, y: cornerLength))
                }
                .stroke(Color.white, lineWidth: cornerWidth)
                
                // Coin inférieur gauche
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size - cornerLength))
                    path.addLine(to: CGPoint(x: 0, y: size))
                    path.addLine(to: CGPoint(x: cornerLength, y: size))
                }
                .stroke(Color.white, lineWidth: cornerWidth)
                
                // Coin inférieur droit
                Path { path in
                    path.move(to: CGPoint(x: size - cornerLength, y: size))
                    path.addLine(to: CGPoint(x: size, y: size))
                    path.addLine(to: CGPoint(x: size, y: size - cornerLength))
                }
                .stroke(Color.white, lineWidth: cornerWidth)
                
                // Ligne de scan animée
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0),
                                Color.green.opacity(0.8),
                                Color.green.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 2)
                    .offset(y: scannerCoordinator.scanLineOffset)
                    .animation(
                        .linear(duration: 2.0).repeatForever(autoreverses: true),
                        value: scannerCoordinator.scanLineOffset
                    )
            }
            .frame(width: 250, height: 250)
        }
    }
}

// MARK: - Scanner Coordinator

@Observable
class BarcodeScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var isScanning = false
    var scanLineOffset: CGFloat = 0
    
    private let onBarcodeScanned: (String) -> Void
    fileprivate var captureSession: AVCaptureSession?
    private var lastScannedCode: String?
    private var lastScanTime: Date?
    
    init(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned
        super.init()
    }
    
    func startScanning() {
        guard captureSession == nil else { return }
        
        Task {
            await setupCaptureSession()
            
            // Animer la ligne de scan
            await MainActor.run {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    scanLineOffset = 250
                }
            }
        }
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        captureSession = nil
    }
    
    private func setupCaptureSession() async {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Impossible d'accéder à la caméra")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Erreur lors de la création de l'input vidéo: \(error)")
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            print("Impossible d'ajouter l'input vidéo")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .upce]
        } else {
            print("Impossible d'ajouter l'output de métadonnées")
            return
        }
        
        self.captureSession = session
        
        Task.detached { [weak session] in
            session?.startRunning()
        }
    }
    
    // AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        // Éviter les scans multiples du même code
        if let lastCode = lastScannedCode,
           let lastTime = lastScanTime,
           lastCode == stringValue,
           Date().timeIntervalSince(lastTime) < 2.0 {
            return
        }
        
        lastScannedCode = stringValue
        lastScanTime = Date()
        isScanning = true
        
        // Vibration haptique
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // Appeler le callback
        onBarcodeScanned(stringValue)
    }
}

// MARK: - Camera Preview Representable

struct BarcodeScannerRepresentable: UIViewRepresentable {
    let coordinator: BarcodeScannerCoordinator
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        // Ajouter la preview layer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let session = coordinator.captureSession {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.frame = view.bounds
                previewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Mettre à jour la frame de la preview layer si nécessaire
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    BarcodeScannerView { barcode in
        print("Code scanné: \(barcode)")
    }
}
