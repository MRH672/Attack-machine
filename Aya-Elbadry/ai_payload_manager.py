#!/usr/bin/env python

"""
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
AI Payload Manager - Main interface for AI-powered payload management
"""

from __future__ import print_function

import os
import sys
import argparse

# Add lib to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lib'))

try:
    from lib.ai_payload_generator import AIPayloadGenerator
    from lib.ai_payload_integrator import AIPayloadIntegrator
    HAS_AI = True
except ImportError as e:
    print(f"[!] AI modules not available: {e}")
    HAS_AI = False

class AIPayloadManager:
    """Main manager for AI payload operations"""
    
    def __init__(self):
        if HAS_AI:
            self.generator = AIPayloadGenerator()
            self.integrator = AIPayloadIntegrator()
        else:
            self.generator = None
            self.integrator = None
    
    def generate(self, payload_type='boolean', waf_type=None, count=5):
        """Generate new payloads"""
        if not self.generator:
            print("[!] AI Generator not available")
            return
        
        print(f"[*] Generating {count} {payload_type} payloads for {waf_type or 'general WAF'}...")
        
        generated = []
        for i in range(count):
            payload, path = self.generator.generate_new_payload(payload_type, waf_type)
            generated.append({
                'payload': payload,
                'evolution_path': path,
                'waf_type': waf_type
            })
            print(f"\n[+] Payload #{i+1}:")
            print(f"    {payload}")
            print(f"    Evolution: {' -> '.join(path[:3])}...")
        
        return generated
    
    def learn(self, payload, success, waf_type=None, reason=None):
        """Learn from a test result"""
        if not self.integrator:
            print("[!] AI Integrator not available")
            return
        
        self.integrator.learn_from_result(payload, success, waf_type, reason)
    
    def update(self):
        """Update payloads automatically"""
        if not self.integrator:
            print("[!] AI Integrator not available")
            return False
        
        return self.integrator.auto_update_payloads()
    
    def analyze(self):
        """Analyze performance"""
        if not self.integrator:
            print("[!] AI Integrator not available")
            return None
        
        return self.integrator.analyze_performance()
    
    def recommend(self, waf_type=None):
        """Get recommendations"""
        if not self.integrator:
            print("[!] AI Integrator not available")
            return []
        
        return self.integrator.get_smart_recommendations(waf_type)

def main():
    parser = argparse.ArgumentParser(
        description='AI-Powered Payload Manager for sqlmap',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Generate new payloads
  python ai_payload_manager.py generate --type boolean --waf Cloudflare --count 10
  
  # Update payloads automatically
  python ai_payload_manager.py update
  
  # Analyze performance
  python ai_payload_manager.py analyze
  
  # Get recommendations
  python ai_payload_manager.py recommend --waf Cloudflare
        '''
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Generate command
    gen_parser = subparsers.add_parser('generate', help='Generate new payloads')
    gen_parser.add_argument('--type', choices=['boolean', 'error', 'time', 'union'], 
                          default='boolean', help='Payload type')
    gen_parser.add_argument('--waf', help='Target WAF type')
    gen_parser.add_argument('--count', type=int, default=5, help='Number of payloads to generate')
    
    # Update command
    subparsers.add_parser('update', help='Update payloads automatically')
    
    # Analyze command
    subparsers.add_parser('analyze', help='Analyze performance')
    
    # Recommend command
    rec_parser = subparsers.add_parser('recommend', help='Get recommendations')
    rec_parser.add_argument('--waf', help='Target WAF type')
    
    # Learn command
    learn_parser = subparsers.add_parser('learn', help='Learn from test result')
    learn_parser.add_argument('--payload', required=True, help='Payload that was tested')
    learn_parser.add_argument('--success', action='store_true', help='Payload was successful')
    learn_parser.add_argument('--waf', help='WAF type')
    learn_parser.add_argument('--reason', help='Failure reason if unsuccessful')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = AIPayloadManager()
    
    if args.command == 'generate':
        manager.generate(args.type, args.waf, args.count)
    
    elif args.command == 'update':
        if manager.update():
            print("\n[+] Update completed successfully!")
        else:
            print("\n[!] Update failed")
    
    elif args.command == 'analyze':
        analysis = manager.analyze()
        if analysis:
            print("\n[*] Performance Analysis")
            print("=" * 50)
            print(f"Total Successful: {analysis['total_successful']}")
            print(f"Total Failed: {analysis['total_failed']}")
            print(f"Success Rate: {analysis['success_rate']:.2f}%")
            
            if analysis['top_obfuscations']:
                print("\nTop Obfuscation Techniques:")
                for tech, count in analysis['top_obfuscations'].items():
                    print(f"  - {tech}: {count}")
            
            if analysis['waf_performance']:
                print("\nWAF Performance:")
                for waf, perf in analysis['waf_performance'].items():
                    print(f"  - {waf}: {perf['success_count']} successes")
    
    elif args.command == 'recommend':
        recommendations = manager.recommend(args.waf)
        if recommendations:
            print(f"\n[*] Recommendations for {args.waf or 'general WAF'}:")
            for i, rec in enumerate(recommendations, 1):
                print(f"\n[{i}] {rec['type']}")
                print(f"    Confidence: {rec['confidence']}")
                print(f"    Reason: {rec['reason']}")
                if 'payload' in rec:
                    print(f"    Payload: {rec['payload']}")
                if 'technique' in rec:
                    print(f"    Technique: {rec['technique']}")
        else:
            print("[!] No recommendations available")
    
    elif args.command == 'learn':
        manager.learn(args.payload, args.success, args.waf, args.reason)
        print("[+] Learning recorded")

if __name__ == '__main__':
    main()

