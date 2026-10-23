#!/usr/bin/env python3
"""Render timed inverted lyric cards to a lossless master and compatible MP4."""
import argparse, json, subprocess, pathlib, fractions, math
p=argparse.ArgumentParser()
p.add_argument('source',type=pathlib.Path);p.add_argument('cards',type=pathlib.Path);p.add_argument('output',type=pathlib.Path)
p.add_argument('--duration',type=float);p.add_argument('--mask-scale',type=int,default=2)
p.add_argument('--frame',help='inner picture area x:y:w:h in source pixels (e.g. footage inside letterbox bars); default is the full frame')
a=p.parse_args()
def run(cmd): subprocess.run([str(x) for x in cmd],check=True)
info=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(a.source)]))
v=next(s for s in info['streams'] if s['codec_type']=='video')
w,h=v['width'],v['height']; rate=v['avg_frame_rate'];fps=float(fractions.Fraction(rate))
duration=a.duration or float(v.get('duration',info['format']['duration']))
if any(s.get('rotation',0) for s in v.get('side_data_list',[])): raise SystemExit('Normalize rotation before rendering.')
if a.mask_scale < 1: raise SystemExit('Mask scale must be positive.')
frame=[int(n) for n in a.frame.split(':')] if a.frame else [0,0,w,h]
if len(frame)!=4 or frame[2]<=0 or frame[3]<=0 or frame[0]<0 or frame[1]<0 or frame[0]+frame[2]>w or frame[1]+frame[3]>h: raise SystemExit('Frame must be x:y:w:h inside the source.')
cards=json.loads(a.cards.read_text());prev=0
for c in cards:
 assert prev <= c['start'] < c['end'], 'Overlapping or invalid cards'
 assert len(c['rows'])==2 and all(c['rows']), 'Expected two nonempty rows'
 starts=[word['start'] for row in c['rows'] for word in row]
 assert starts==sorted(starts) and all(c['start']<=s<c['end'] for s in starts), 'Invalid word onsets'
 prev=c['end']
a.output.mkdir(parents=True,exist_ok=True)
exe=a.output/'render-masks'
run(['swiftc',pathlib.Path(__file__).with_name('render-masks.swift'),'-o',exe])
run([exe,a.cards,a.output,w*a.mask_scale,h*a.mask_scale,fps,duration,','.join(str(n*a.mask_scale) for n in frame)])
master=a.output/'lyrics-master.mkv';mp4=a.output/'lyrics-full.mp4'
graph=f'[0:v]format=gbrp,split[base][copy];[copy]negate[neg];[1:v]scale={w}:{h}:flags=lanczos,format=gbrp[mask];[base][neg][mask]maskedmerge,split[master][share];[share]scale=in_range=pc:out_range=tv:out_color_matrix=bt709,format=yuv420p[mp4]'
cmd=['ffmpeg','-hide_banner','-loglevel','warning','-y','-i',a.source,'-framerate',rate,'-i',a.output/'masks/%04d.png','-filter_complex',graph,'-map','[master]','-map','0:a:0?','-t',duration,'-c:v','ffv1','-level','3','-pix_fmt','bgr0','-c:a','copy',master,'-map','[mp4]','-map','0:a:0?','-t',duration,'-c:v','libx264','-crf','12','-preset','slow','-pix_fmt','yuv420p','-color_range','tv','-colorspace','bt709','-color_primaries','bt709','-color_trc','bt709','-c:a','copy','-movflags','+faststart',mp4]
run(cmd)
(a.output/'render-settings.json').write_text(json.dumps({'source':str(a.source),'cards':str(a.cards),'width':w,'height':h,'fps':rate,'duration':duration,'mask_scale':a.mask_scale,'frame':frame,'master':'FFV1 RGB lossless','share':'H.264 CRF 12 slow','audio':'stream copy'},indent=2))
print(master);print(mp4)
