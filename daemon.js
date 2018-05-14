let { spawn, exec } = require('child_process')
let fs = require('fs')
let videoDrive = process.env.VIDEO_PATH || '/media/videodrive/'
let shouldRunFlag = process.env.RUN_FLAG || '/opt/recorder-scripts/RUN_FLAG'
let path = require('path')
let shouldRun = fs.existsSync(shouldRunFlag)
let http = require('http')
let SerialPort = require('serialport');
let Delimiter = require('parser-delimiter')
let port = new SerialPort('/dev/ttyUSB0', {
  baudRate: 9600
})
let { ERROR_STATUS, STATUS_UPDATE, COMMANDS, head, tail } = require('./protocol.js')
let parser = port.pipe(new Delimiter({ delimiter: '153' }))
let isRunning = false

parser.on('data', (data) => {
  let val = data.toString('utf8')
  let serviceStart = STATUS_UPDATE.SERVICE_START
  let serviceStop = STATUS_UPDATE.SERVICE_STOP

  if (serviceStart.indexOf(val) > -1) {
    return start()
  }

  if (serviceStop.indexOf(val) > -1) {
    return stop()
  }
})

let cam1, cam2

let record = () => {
  if (isRunning) {
	console.log('Already running');
	return;
  }
  let dirs = [
    `${videoDrive}CAMERA_1`,
    `${videoDrive}CAMERA_2`
  ]

  dirs.forEach((dir) => {
    if (fs.existsSync(dir)) return
    fs.mkdirSync(dir)
  })

  console.log(`/opt/recorder-scripts/record_cam1.sh CAMERA_1 ${videoDrive}CAMERA_1`)
  cam1 = spawn('/opt/recorder-scripts/record_cam1.sh', ['CAMERA_1', dirs[0]], {
    uid: 1000,
    gid: 1000,
    detached: true
  })

  console.log(`/opt/recorder-scripts/record_cam2.sh CAMERA_2 ${videoDrive}CAMERA_2`)
  cam2 = spawn('/opt/recorder-scripts/record_cam2.sh', ['CAMERA_2', dirs[1]], {
    uid: 1000,
    gid: 1000,
    detached: true
  })

  cam1.stdout.on('data', (data) => {
    console.log('hauhauha', data)
  })

  cam1.stdout.on('error', (data) => {
    console.log('ERROR CAM1')
    process.exit(1)
  })

  cam2.stdout.on('error', (data) => {
    console.log('ERROR CAM2')
    process.exit(1)
  })
  isRunning = true;
}

http.createServer((request, response) => {
  let body = ''

  request.on('data', function (data) {
    body += data

    if (body.length > 1e6)
    request.connection.destroy()
  });

  request.on('end', function () {
    if (request.url.indexOf('/api') > -1) {
      switch(body) {
        case 'start_video':
          start()
          response.end('OK')
        break
        case 'end_video':
          stop()
          response.end('OK')
        break
      }
    } else {
      return response.end(fs.readFileSync('/opt/recorder-scripts/index.html'))
    }
  })
}).listen(1337)

function start() {
  console.log('Starting video..')
  writeFlag()
  record()
}

function stop() {
  removeFlag()
console.log('isRunning flase')
isRunning = false;
  try {
    cam1.stdin.pause()
    process.kill(-cam1.pid)

    cam2.stdin.pause()
    process.kill(-cam2.pid)
  } catch(e) {
console.log('catch')
    exec('killall -9 ffmpeg')
  }
}

let writeFlag = () => {
  return fs.writeFileSync(shouldRunFlag, 'true', 'utf-8')
}

let removeFlag = () => {
  if (fs.existsSync(shouldRunFlag)) {
    fs.unlinkSync(shouldRunFlag)
  } else {
    console.log('File does not exist.')
  }
}

if (shouldRun) {
  console.log('Flag is set, starting record')
  record()
}
