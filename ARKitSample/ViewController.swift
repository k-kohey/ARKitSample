import UIKit
import ARKit

struct SocialAcctount {
    static let github: Self = .init(
        image: UIImage(named: "github")!,
        url: URL(string: "https://github.com/k-kohey")!
    )
    static let twitter: Self = .init(
        image: UIImage(named: "twitter")!,
        url: URL(string: "https://twitter.com/k_koheyi")!
    )
    static let zenn: Self = .init(
        image: UIImage(named: "zenn")!,
        url: URL(string: "https://zenn.dev/k_koheyi")!
    )

    let node: SCNNode
    let url: URL

    private init(image: UIImage, url: URL) {
        let node = SCNNode()
        let geometry = SCNPlane(
            width: 0.05, height: 0.05 * image.size.height / image.size.width
        )
        geometry.firstMaterial!.diffuse.contents = image
        node.geometry = geometry

        self.node = node
        self.url = url
    }
}

final class ViewController: UIViewController {
    private let sceneView = ARSCNView()
    private let tapGesture = UITapGestureRecognizer()

    override func loadView() {
        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.addGestureRecognizer(tapGesture)

        tapGesture.addTarget(self, action: #selector(didTapSceneView))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARImageTrackingConfiguration()

        let referenceImage = ARReferenceImage(
            UIImage(named: "avatar")!.cgImage!,
            orientation: .up,
            physicalWidth: .init(0.08)
        )

        Task {
            do {
                try await referenceImage.validate()
                configuration.trackingImages = [referenceImage]
                sceneView.session.run(
                    configuration,
                    options: [.removeExistingAnchors, .resetTracking]
                )
            } catch {
                assertionFailure("validation failure: \(String(describing: error))")
            }
        }
    }

    @objc private func didTapSceneView(_ sender: UITapGestureRecognizer) {
        let node = sceneView.hitTest(sender.location(in: sceneView)).first?.node

        switch node {
        case SocialAcctount.github.node:
            UIApplication.shared.open(SocialAcctount.github.url)
        case SocialAcctount.twitter.node:
            UIApplication.shared.open(SocialAcctount.twitter.url)
        case SocialAcctount.zenn.node:
            UIApplication.shared.open(SocialAcctount.zenn.url)
        default:
            return
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }

        let githubNode = SocialAcctount.github.node
        githubNode.position.x += 0.1
        githubNode.eulerAngles.x -= .pi / 2
        node.addChildNode(githubNode)

        let twitterNode = SocialAcctount.twitter.node
        twitterNode.position.x -= 0.1
        twitterNode.eulerAngles.x -= .pi / 2
        node.addChildNode(twitterNode)

        let zennNode = SocialAcctount.zenn.node
        zennNode.position.z += 0.1
        zennNode.eulerAngles.x -= .pi / 2
        node.addChildNode(zennNode)
    }
}
