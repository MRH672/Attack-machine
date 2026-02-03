#!/usr/bin/env python

"""
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
AI Payload Integrator - Integrates AI-generated payloads with sqlmap
"""

from __future__ import print_function

import os
import sys
import xml.etree.ElementTree as ET
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

try:
    from lib.ai_payload_generator import AIPayloadGenerator
    HAS_AI_GENERATOR = True
except ImportError:
    HAS_AI_GENERATOR = False
    print("[!] AI Payload Generator not available")

class AIPayloadIntegrator:
    """
    Integrates AI-generated payloads with sqlmap's payload system
    """
    
    def __init__(self):
        self.base_path = os.path.dirname(os.path.dirname(__file__))
        self.payloads_dir = os.path.join(self.base_path, "data", "xml", "payloads")
        self.ai_payloads_file = os.path.join(self.payloads_dir, "ai_generated_payloads.xml")
        self.new_payloads_file = os.path.join(self.payloads_dir, "new_payloads.xml")
        
        if HAS_AI_GENERATOR:
            self.generator = AIPayloadGenerator()
        else:
            self.generator = None
    
    def merge_payloads(self, source_file, target_file):
        """Merge payloads from source file into target file"""
        try:
            # Parse target file
            target_tree = ET.parse(target_file)
            target_root = target_tree.getroot()
            
            # Parse source file
            source_tree = ET.parse(source_file)
            source_root = source_tree.getroot()
            
            # Add AI-generated payloads
            added_count = 0
            for test in source_root.findall('test'):
                # Check if similar payload already exists
                title = test.find('title')
                if title is not None:
                    title_text = title.text or ''
                    
                    # Check for duplicates
                    is_duplicate = False
                    for existing_test in target_root.findall('test'):
                        existing_title = existing_test.find('title')
                        if existing_title is not None and existing_title.text == title_text:
                            is_duplicate = True
                            break
                    
                    if not is_duplicate:
                        target_root.append(test)
                        added_count += 1
            
            # Save merged file
            target_tree.write(target_file, encoding='utf-8', xml_declaration=True)
            
            return added_count
        except Exception as e:
            print(f"[!] Error merging payloads: {e}")
            return 0
    
    def auto_update_payloads(self):
        """Automatically update payloads using AI"""
        if not self.generator:
            print("[!] AI Generator not available")
            return False
        
        print("[*] Starting AI payload update...")
        
        # Generate new payloads
        print("[*] Generating new payloads based on learning...")
        
        # Generate for different WAF types
        waf_types = ['Cloudflare', 'Akamai', 'Imperva', 'Incapsula', 'WordFence']
        generated_count = 0
        
        for waf_type in waf_types:
            for payload_type in ['boolean', 'error', 'time', 'union']:
                try:
                    new_payload, path = self.generator.generate_new_payload(payload_type, waf_type)
                    # Record as potential (needs testing)
                    generated_count += 1
                except Exception as e:
                    print(f"[!] Error generating payload for {waf_type}/{payload_type}: {e}")
        
        print(f"[+] Generated {generated_count} new payload variants")
        
        # Export to XML
        if self.generator.export_to_xml(self.ai_payloads_file):
            print(f"[+] Exported AI-generated payloads to: {self.ai_payloads_file}")
            
            # Merge with existing payloads
            if os.path.exists(self.ai_payloads_file):
                added = self.merge_payloads(self.ai_payloads_file, self.new_payloads_file)
                print(f"[+] Merged {added} new payloads into new_payloads.xml")
                return True
        
        return False
    
    def learn_from_result(self, payload, success, waf_type=None, reason=None):
        """Learn from a payload test result"""
        if not self.generator:
            return
        
        if success:
            self.generator.record_success(payload, waf_type)
            print(f"[+] Recorded successful payload against {waf_type or 'unknown WAF'}")
        else:
            self.generator.record_failure(payload, reason, waf_type)
            print(f"[+] Recorded failed payload: {reason}")
    
    def get_smart_recommendations(self, waf_type=None):
        """Get smart recommendations based on AI learning"""
        if not self.generator:
            return []
        
        return self.generator.get_recommendations(waf_type)
    
    def analyze_performance(self):
        """Analyze performance of AI-generated payloads"""
        if not self.generator:
            return None
        
        patterns = self.generator.analyze_patterns()
        
        analysis = {
            'total_successful': len(self.generator.successful_payloads),
            'total_failed': len(self.generator.failed_payloads),
            'success_rate': 0,
            'top_obfuscations': {},
            'waf_performance': {}
        }
        
        if analysis['total_successful'] + analysis['total_failed'] > 0:
            analysis['success_rate'] = (
                analysis['total_successful'] / 
                (analysis['total_successful'] + analysis['total_failed']) * 100
            )
        
        # Top obfuscations
        if patterns['common_obfuscations']:
            analysis['top_obfuscations'] = dict(
                sorted(
                    patterns['common_obfuscations'].items(),
                    key=lambda x: x[1],
                    reverse=True
                )[:5]
            )
        
        # WAF performance
        for waf_type, waf_data in self.generator.waf_patterns.items():
            analysis['waf_performance'][waf_type] = {
                'success_count': waf_data['count'],
                'recent_payloads': len(waf_data['successful_patterns'])
            }
        
        return analysis

def main():
    """Main function"""
    integrator = AIPayloadIntegrator()
    
    print("[*] AI Payload Integrator")
    print("[*] =====================")
    
    # Analyze current performance
    print("\n[*] Analyzing current performance...")
    analysis = integrator.analyze_performance()
    if analysis:
        print(f"[+] Total successful payloads: {analysis['total_successful']}")
        print(f"[+] Total failed payloads: {analysis['total_failed']}")
        print(f"[+] Success rate: {analysis['success_rate']:.2f}%")
        
        if analysis['top_obfuscations']:
            print("\n[+] Top obfuscation techniques:")
            for technique, count in analysis['top_obfuscations'].items():
                print(f"    - {technique}: {count} uses")
        
        if analysis['waf_performance']:
            print("\n[+] WAF performance:")
            for waf_type, perf in analysis['waf_performance'].items():
                print(f"    - {waf_type}: {perf['success_count']} successes")
    
    # Auto-update
    print("\n[*] Running auto-update...")
    if integrator.auto_update_payloads():
        print("[+] Auto-update completed successfully")
    else:
        print("[!] Auto-update failed")

if __name__ == '__main__':
    main()

