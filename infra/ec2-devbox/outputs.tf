output "instance_id" {
  description = "EC2 instance id. `devbox` finds it by Name tag, so you rarely need this."
  value       = aws_instance.devbox.id
}

output "public_ip" {
  description = "Current public IP. Changes on every stop/start — `devbox up` rewrites your SSH config each time, so you never hardcode it."
  value       = aws_instance.devbox.public_ip
}

output "work_volume_id" {
  description = "Persistent work volume (survives instance replacement)."
  value       = aws_ebs_volume.work.id
}

output "next_steps" {
  value = <<-EOT

    Provisioned. Now, from your laptop:

      devbox provision    # installs tooling + your dotfiles over SSH (agent-forwarded)
      devbox up           # start + attach tmux
      devbox down         # stop it now (or let idle-stop do it)

  EOT
}
